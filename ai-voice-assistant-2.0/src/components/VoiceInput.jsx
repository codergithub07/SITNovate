import React, { useState, useRef, useEffect } from 'react';
import styles from '../styles/VoiceInput.module.css';

const VoiceInput = ({ onVoiceInput, selectedLanguage }) => { // Receive selectedLanguage prop
    const [isListening, setIsListening] = useState(false);
    const recognitionRef = useRef(null);

    useEffect(() => {
        if (!("webkitSpeechRecognition" in window)) {
            console.warn("Speech recognition is not supported in this browser. Try using Chrome.");
            return;
        }

        recognitionRef.current = new window.webkitSpeechRecognition();
        recognitionRef.current.continuous = false;
        recognitionRef.current.interimResults = false;
        recognitionRef.current.lang = selectedLanguage; // Set language from prop

        recognitionRef.current.onstart = () => setIsListening(true);
        recognitionRef.current.onresult = (event) => {
            const transcript = event.results[0][0].transcript;
            onVoiceInput(transcript);
            setIsListening(false);
        };
        recognitionRef.current.onerror = (event) => {
            console.error("Speech recognition error:", event.error);
            setIsListening(false);
        };
        recognitionRef.current.onend = () => {
            setIsListening(false);
        };

        return () => {
            if (recognitionRef.current) {
                recognitionRef.current.stop();
                recognitionRef.current.onstart = null;
                recognitionRef.current.onresult = null;
                recognitionRef.current.onerror = null;
                recognitionRef.current.onend = null;
            }
        };
    }, [onVoiceInput, selectedLanguage]); // Add selectedLanguage to dependency array

    const handleVoiceButtonClick = () => {
        if (!recognitionRef.current) return;

        if (!isListening) {
            try {
                recognitionRef.current.start();
            } catch (error) {
                console.error("Error starting speech recognition:", error);
                setIsListening(false);
            }
        } else {
            recognitionRef.current.stop();
            setIsListening(false);
        }
    };

    return (
        <button
            className={`${styles.voiceButton} ${isListening ? styles.listening : ''}`}
            onClick={handleVoiceButtonClick}
            disabled={isListening}
        >
            {isListening ? 'Listening...' : 'Voice Input'}
        </button>
    );
};

export default VoiceInput;