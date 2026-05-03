import React from 'react';
import AgentChat from './components/AgentChat';
import './App.css';

function App() {
  return (
    <div className="app">
      <header className="app-header">
        <div className="header-content">
          <h1>🤖 DevOps Agent Orchestrator</h1>
          <p>Intelligent multi-agent system for DevOps/SRE automation</p>
        </div>
        <div className="header-status">
          <span className="status-badge online">● Online</span>
        </div>
      </header>
      <AgentChat />
    </div>
  );
}

export default App;
