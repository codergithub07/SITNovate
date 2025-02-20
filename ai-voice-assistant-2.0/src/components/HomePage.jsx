import React from 'react';
import styles from '../styles/HomePage.module.css';

const HomePage = () => {
    return (
        <div className={styles.homePage}>
            <h1>Welcome to the AI Character Chat</h1>
            <p>
                Meet our unique AI characters who are ready to answer your questions!
                Choose your character and start chatting.
            </p>
            <ul>
                <h3>Sample Input You Could Use</h3>
                <li><strong>Rude Banker:</strong>  A banker who is not very enthusiastic about answering questions.</li>
                <li><strong>Humble Actor:</strong> A kind actor who loves to interact with fans.</li>
                {/* Add more characters as needed */}
            </ul>
            <p>
                Click on a character to start chatting! (We'll add character selection later)
            </p>
        </div>
    );
};

export default HomePage;