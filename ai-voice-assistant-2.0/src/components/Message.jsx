import React from 'react';
import styles from '../styles/Message.module.css';

const Message = ({ sender, text }) => {
    const messageClass = sender === 'user' ? styles.userMessage : styles.botMessage;
    return (
        <div className={`${styles.message} ${messageClass}`}>
            <div className={styles.messageContent}>{text}</div>
        </div>
    );
};

export default Message;