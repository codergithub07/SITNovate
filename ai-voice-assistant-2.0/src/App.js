import React, { useState } from 'react';
import HomePage from './components/HomePage';
import ChatInterface from './components/ChatInterface';
import styles from './styles/App.module.css';

function App() {
    const [characterPromptInput, setCharacterPromptInput] = useState('');
    const [selectedLanguage, setSelectedLanguage] = useState('en');
    const [isChatting, setIsChatting] = useState(false);

    const handleStartChat = () => {
        setIsChatting(true);
    };

    return (
        <div className={styles.app}>
            {!isChatting ? (
                <>
                    <HomePage />
                    <div className={styles.characterSelect}>
                        <h2>Create Your AI Character & Select Language</h2>
                        <input
                            type="text"
                            placeholder="Describe your AI character (e.g., a wise old wizard, a cheerful robot)"
                            className={styles.characterInput}
                            value={characterPromptInput}
                            onChange={(e) => setCharacterPromptInput(e.target.value)}
                        />
                        {/* Removed Gender Selection Dropdown */}
                        <select
                            className={styles.languageSelect}
                            value={selectedLanguage}
                            onChange={(e) => setSelectedLanguage(e.target.value)}
                        >
                            <option value="en">English</option>
                            <option value="es">Spanish</option>
                            <option value="fr">French</option>
                            <option value="de">German</option>
                            <option value="hi">Hindi</option>
                            <option value="ma">Marathi</option>
                            <option value="zh-CN">Chinese (Simplified)</option>
                            <option value="ja">Japanese</option>
                            <option value="ka">Kannada</option>
                            {/* Add more languages as needed */}
                        </select>
                        <button onClick={handleStartChat} disabled={!characterPromptInput.trim()}>
                            Start Chat
                        </button>
                    </div>
                </>
            ) : (
                <ChatInterface
                    characterPrompt={characterPromptInput}
                    selectedLanguage={selectedLanguage}
                />
            )}
        </div>
    );
}

export default App;