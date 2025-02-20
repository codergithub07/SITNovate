// const geminiClassifier=process.env.GEMINI_CLASSIFICATION_API_KEY;
import React, { useState, useRef, useEffect } from 'react';
import styles from '../styles/ChatInterface.module.css';
import Message from './Message';
import VoiceInput from './VoiceInput';

const { GoogleGenerativeAI } = require("@google/generative-ai");

const voiceIdMap = {
    "male_voice": 'P1bg08DkjqiVEzOn76yG', //  Example male voice ID - REPLACE WITH YOUR ACTUAL MALE VOICE ID FROM ELEVENLABS or use process.env.ELEVENLABS_VOICE_ID_MALE
    "female_voice": 'EXAVITQu4vr4xnSDxMaL', // Example female voice ID - REPLACE WITH YOUR ACTUAL FEMALE VOICE ID FROM ELEVENLABS or use process.env.ELEVENLABS_VOICE_ID_FEMALE
};

console.log("Initial voiceIdMap:", voiceIdMap); // Log voiceIdMap right after definition
const geminiClassifier='AIzaSyBCoZwHQk7Z5WO9z1naGyf2nt6mAx4nLWg';


const ChatInterface = ({ characterPrompt, selectedLanguage }) => {
    const [messages, setMessages] = useState([]);
    const [inputText, setInputText] = useState('');
    const chatContainerRef = useRef(null);

    const geminiApiKey = 'AIzaSyB1aRELut1KkU3Nxvae7HvYtWVAmkrIJcc'; // Single Gemini API Key
    const elevenLabsApiKey = process.env.REACT_APP_ELEVENLABS_API_KEY;
    const classificationApiKey = 'AIzaSyBCoZwHQk7Z5WO9z1naGyf2nt6mAx4nLWg'; // Use separate API key for classification

    const genAI = new GoogleGenerativeAI(geminiApiKey);
    const genAIClassification = new GoogleGenerativeAI(classificationApiKey); // Separate instance for classification

    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-thinking-exp-01-21" });
    const classificationModel = genAIClassification.getGenerativeModel({ model: "gemini-2.0-flash-thinking-exp-01-21" }); // Use classification-specific instance

    const generationConfig = {
        temperature: 0.7,
        topP: 0.95,
        topK: 64,
        maxOutputTokens: 65536,
    };


    const sendMessageToGemini = async (messageText) => {
        const languageName = getSelectedLanguageName(selectedLanguage);
        const fullPrompt = `You are an AI assistant with the following character: ${characterPrompt}.

**IMPORTANT: The user will ask questions and communicate with you in ${languageName} language.  You MUST respond to ALL user queries and messages in ${languageName} language.**

**Your ENTIRE response MUST be in ${languageName}. Do not respond in English or any other language.  If the user asks in ${languageName}, you reply in ${languageName}.**

Consider this as a **zero-shot translation task**:  Understand the user's request and generate a helpful and relevant response *directly* in ${languageName}, maintaining your assigned character.

User query in ${languageName}: ${messageText}`;
        const chatSession = model.startChat({
            generationConfig,
            history: messages.map(msg => ({
                role: msg.sender === 'user' ? 'user' : 'model',
                parts: [{ text: msg.text }],
            })),
        });

        try {
            const geminiResponse = await model.generateContent({
                generationConfig: generationConfig,
                contents: [{ parts: [{ text: fullPrompt }] }]
            });
            const responseText = geminiResponse.response.text();
            return responseText;
        } catch (error) {
            console.error("Gemini API error:", error);
            return "Sorry, I encountered an error while processing your request.";
        }
    };

    const classifyCharacterGender = async (characterDescription) => {
        try {
            const classificationPrompt = `Classify the character described below as either "male" or "female". If the gender is ambiguous or neutral, classify as "female". Just return either "male" or "female".

            Character description: ${characterDescription}

            Gender: `;

            console.log("Classification Prompt:", classificationPrompt); // Log the prompt

            const response = await classificationModel.generateContent({ // Use classificationModel which is initialized with geminiClassifier
                generationConfig: { maxOutputTokens: 100 },
                contents: [{ parts: [{ text: classificationPrompt }] }]
            });

            console.log("Full Classification Response:", response); // Log the entire response object
            console.log("Classification Response Text:", response.response.text()); // Log response text specifically


            let genderCategory = response.response.text().trim().toLowerCase();

            if (genderCategory !== 'male' && genderCategory !== 'female') {
                console.warn(`Gemini classified gender as "${genderCategory}", which is invalid. Falling back to 'female'.`);
                genderCategory = "female"; // Default to female if classification is unclear
            }

            console.log(`Character classified as gender: ${genderCategory}`);
            return genderCategory;

        } catch (error) {
            console.error("Character gender classification error:", error);
            console.error("Full classification error object:", error); // Log full error object for debugging
            return "female"; // Default to female on error
        }
    };


    const textToSpeechElevenLabs = async (text) => {
        if (!elevenLabsApiKey) {
            console.warn("ElevenLabs API key not set.");
            return null;
        }

        let currentVoiceId;
        try {
            const genderClassification = await classifyCharacterGender(characterPrompt);
            console.log(`Gender classification result: ${genderClassification}`);

            // Debugging logs - VERY IMPORTANT to check these in your browser console
            console.log("voiceIdMap inside textToSpeechElevenLabs:", voiceIdMap);
            console.log("voiceIdMap['male_voice']:", voiceIdMap["male_voice"]);
            console.log("voiceIdMap['female_voice']:", voiceIdMap["female_voice"]);
            console.log("genderClassification value:", genderClassification);


            if (genderClassification === 'male') {
                currentVoiceId = voiceIdMap["male_voice"];
            } else {
                currentVoiceId = voiceIdMap["female_voice"];
            }
            console.log(`Selected Voice ID based on gender: ${currentVoiceId}`);

        } catch (classificationError) {
            console.warn("Error during gender classification, defaulting to female voice.", classificationError);
            currentVoiceId = voiceIdMap["female_voice"]; // Default to female voice on error
        }

        if (!currentVoiceId) {
            console.warn("No valid Voice ID found (even after defaulting). Skipping ElevenLabs TTS.");
            return null;
        }


        try {
            const response = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${currentVoiceId}`, {
                method: 'POST',
                headers: {
                    'xi-api-key': elevenLabsApiKey,
                    'Content-Type': 'application/json',
                    'Accept': 'audio/mpeg'
                },
                body: JSON.stringify({
                    text: text,
                    text: text,
                    model_id: "eleven_monolingual_v1",
                    voice_settings: {
                        stability: 0.5,
                        similarity_boost: 0.5
                    }
                })
            });

            if (!response.ok) {
                const errorText = await response.text();
                console.error(`ElevenLabs API error: ${response.status} - ${errorText}`);
                return null;
            }

            const audioBlob = await response.blob();
            const audioUrl = URL.createObjectURL(audioBlob);
            return audioUrl;

        } catch (error) {
            console.error("ElevenLabs TTS error:", error);
            return null;
        }
    };


    const handleSendMessage = async () => {
        if (inputText.trim()) {
            const userMessage = inputText.trim();
            setMessages(currentMessages => [...currentMessages, { sender: 'user', text: userMessage }]);
            setInputText('');

            const botResponseText = await sendMessageToGemini(userMessage);
            setMessages(currentMessages => [...currentMessages, { sender: 'bot', text: botResponseText }]);

            const audioUrl = await textToSpeechElevenLabs(botResponseText);
            if (audioUrl) {
                const audio = new Audio(audioUrl);
                audio.play();
            }
        }
    };

    const handleVoiceInputText = (voiceTranscript) => {
        setInputText(voiceTranscript);
    };

    const getSelectedLanguageName = (langCode) => {
        const languageNames = {
            'en': 'English',
            'es': 'Spanish',
            'fr': 'French',
            'de': 'German',
            'zh-CN': 'Chinese',
            'ja': 'Japanese',
            'hi': 'Hindi',
            'ma': 'Marathi',
            'ka': 'Kannada',
            // ... add more language names if needed
        };
        return languageNames[langCode] || 'English';
    };


    useEffect(() => {
        if (chatContainerRef.current) {
            chatContainerRef.current.scrollTop = chatContainerRef.current.scrollHeight;
        }
    }, [messages]);


    return (
        <div className={styles.chatInterface}>
            <div className={styles.chatHeader}>
                <h2>Chatting as a Custom Character in {getSelectedLanguageName(selectedLanguage)}</h2>
            </div>
            <div className={styles.chatMessages} ref={chatContainerRef}>
                {messages.map((message, index) => (
                    <Message key={index} sender={message.sender} text={message.text} />
                ))}
            </div>
            <div className={styles.chatInputArea}>
                <VoiceInput onVoiceInput={handleVoiceInputText} selectedLanguage={selectedLanguage} />
                <input
                    type="text"
                    className={styles.inputField}
                    placeholder={`Type your message in ${getSelectedLanguageName(selectedLanguage)}...`}
                    value={inputText}
                    onChange={(e) => setInputText(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' ? handleSendMessage() : null}
                />
                <button className={styles.sendButton} onClick={handleSendMessage}>Send</button>
            </div>
        </div>
    );
};

export default ChatInterface;