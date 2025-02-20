# AI Assistant

## Project Overview

**AI Assistant** is a voice-activated AI bot designed to engage users in any language with a unique personality and backstory. This project focuses on creating a conversational AI that is not only multilingual but also deeply characterized, ensuring responses are consistent with its defined persona.

**Prepared by: Group 15 - AI_Visionaries**

## Key Features

*   **Multilingual Voice Interaction:** Understands and responds in any language spoken by the user.
*   **Unique Character and Backstory Integration:**  Each bot possesses a distinct character and backstory (e.g., a rude banker, a humble actor), influencing its responses.
*   **Context-Aware Responses:** Answers are tailored to the bot's personality and relevant to its role.
*   **Real-time Speech-to-Speech (S2S) Communication:** Provides a seamless voice interaction experience.
*   **Visual Cues:** Utilizes icons for voice recognition, language translation, and character representation to enhance user experience.

## How It Works

The AI Assistant operates through the following steps:

1.  **Voice Input & Language Detection:**
    *   The user speaks a query into their microphone.
    *   The system captures the audio.
    *   Speech-to-Text (STT) conversion transcribes the audio into text.
    *   Language detection identifies the language of the user's query.

2.  **Fine-Tuned Model & Character-Based Response:**
    *   The transcribed text is processed by a fine-tuned AI model.
    *   The system checks the query's relevance to the bot's defined character and backstory.
    *   Based on relevance and character, an appropriate response is generated.
    *   If the query is not related to the character, a character-specific message might be generated to guide the conversation back on track.

3.  **Text-to-Speech & Voice Output:**
    *   The generated text response is converted back into audio using Text-to-Speech (TTS) technology.
    *   The audio response is delivered to the user in the same language they used for their query.

## Architecture

This project has been explored in two versions, leveraging different frameworks and technologies:

### Version 1: Flutter

*   **Framework:** Flutter (for cross-platform mobile application development)
*   **Architecture:** Modular design, dividing the application into components for maintainability and scalability.
*   **User Flow:**
    1.  User selects a character from the `HomePage`.
    2.  User interacts with the voice assistant on the `MainPage`.
*   **Key Components:**
    *   `Main.dart`: Initializes the application.
    *   `HomePage.dart`:  Character selection screen, navigates to `MainPage`.
    *   `MainPage.dart`:  Core screen for voice assistant interaction.
    *   `OpenaiService.dart`:  Handles communication with the OpenAI API to fetch responses.
    *   `OpenAITTS.dart`:  Utilizes OpenAI's Text-to-Speech engine to convert text responses to audio.
    *   `Pallete.dart`:  Likely manages UI theming and color palettes.
*   **API Integration:**
    *   **OpenAI API:** Used for generating AI responses.
    *   **OpenAI Text-to-Speech Engine:** Used for converting text to speech.

### Version 2: React

*   **Framework:** React (for web application development)
*   **Architecture:**  Focuses on leveraging browser-based and cloud services for a streamlined experience.
*   **User Interaction Flow:**
    *   User provides input via voice or text.
    *   Voice input is converted to text using Speech-to-Text services (Local Mic STT, Browser STT, Google STT API, Google Cloud STT).
    *   Language is detected before AI processing.
*   **AI Processing:**
    *   User query is sent to the Gemini model.
    *   Query is enriched with character prompts to align with the defined personality.
    *   Processed by the Gemini Thinking API to generate a response in the selected language.
*   **Output & Voice:**
    *   AI's response is displayed in the Chat UI.
    *   Text response is converted to speech using ElevenLabs' Text-to-Speech service.
    *   Voice ID is selected based on character settings for a more personalized audio output.
*   **Key Technologies & APIs:**
    *   **Speech-to-Text (STT):** Local Mic STT, Browser STT, Google STT API, Google Cloud STT
    *   **AI Model:** Fine-tuned Gemini Model (Gemini Thinking API)
    *   **Text-to-Speech (TTS):** ElevenLabs API
    *   **Chat UI:** User interface for text-based interaction.

## Scalability & Impact

The AI Assistant project is designed with scalability and efficiency in mind:

*   **Scalable Components:** Modular design allows for independent scaling of individual services based on demand.
*   **Cloud Integration:** Utilizing cloud-based services ensures seamless scaling and high availability.
*   **Faster Responses:** Scalability contributes to quick and reliable performance, enhancing user experience.
*   **Cost-Effective:** Cloud scaling optimizes resource usage, leading to cost efficiency.

## Technologies Used

*   **Version 1:** Flutter, Dart, OpenAI API, OpenAI TTS
*   **Version 2:** React, JavaScript, Gemini API, ElevenLabs API, Web Speech API (for Browser STT), Google Cloud STT (optional)

## Getting Started (If Applicable)

[**Note:** If this README is for a code repository, you should add instructions on how to set up and run the project. For example, steps to clone the repository, install dependencies, configure API keys, and run the application. If this is purely a presentation README, you can remove or modify this section.]

For developers looking to contribute or run this project:

1.  **Clone the repository:** `git clone [repository-url]`
2.  **Navigate to the project directory:** `cd [project-directory]`
3.  **[Add specific instructions for Flutter or React version setup, e.g., install dependencies, set up API keys, run commands etc.]**

## Team

*   Group 15: AI\_Visionaries


**Thank you for reviewing our AI Assistant project!**
