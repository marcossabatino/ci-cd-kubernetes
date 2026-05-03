import React, { useState, useEffect, useRef } from 'react';
import { getAgents, sendMessage } from '../services/api';

export default function AgentChat() {
  const [agents, setAgents] = useState([]);
  const [selectedAgent, setSelectedAgent] = useState(null);
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    loadAgents();
  }, []);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const loadAgents = async () => {
    try {
      setError(null);
      const response = await getAgents();
      setAgents(response.data.data);
      if (response.data.data.length > 0) {
        setSelectedAgent(response.data.data[0].name);
      }
    } catch (err) {
      setError('Failed to load agents. Is backend running?');
      console.error(err);
    }
  };

  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (!input.trim() || !selectedAgent || loading) return;

    const userMessage = input.trim();
    setInput('');
    setMessages(prev => [...prev, { role: 'user', content: userMessage }]);
    setLoading(true);
    setError(null);

    try {
      const response = await sendMessage(selectedAgent, userMessage, messages);
      const agentResponse = response.data.data;
      setMessages(prev => [...prev, {
        role: 'agent',
        content: agentResponse.content,
        agent: agentResponse.agent,
        metadata: agentResponse.metadata
      }]);
    } catch (err) {
      setError(`Error communicating with agent: ${err.message}`);
      setMessages(prev => prev.slice(0, -1));
    } finally {
      setLoading(false);
    }
  };

  const agentInfo = agents.find(a => a.name === selectedAgent);

  return (
    <div className="agent-chat">
      <div className="chat-container">
        {/* Sidebar */}
        <div className="sidebar">
          <h2>Agents</h2>
          {error && <div className="error-banner">{error}</div>}
          <div className="agents-list">
            {agents.length === 0 ? (
              <div className="no-agents">No agents available</div>
            ) : (
              agents.map(agent => (
                <button
                  key={agent.name}
                  className={`agent-btn ${selectedAgent === agent.name ? 'active' : ''}`}
                  onClick={() => {
                    setSelectedAgent(agent.name);
                    setMessages([]);
                  }}
                >
                  <span className="agent-name">{agent.name}</span>
                  <span className="agent-status">●</span>
                </button>
              ))
            )}
          </div>
        </div>

        {/* Main Chat */}
        <div className="chat-main">
          {/* Agent Info */}
          {agentInfo && (
            <div className="agent-header">
              <h1>{agentInfo.name}</h1>
              <p className="description">{agentInfo.description}</p>
              <div className="keywords">
                <strong>Topics:</strong> {agentInfo.keywords.slice(0, 5).join(', ')}
              </div>
            </div>
          )}

          {/* Messages */}
          <div className="messages">
            {messages.length === 0 ? (
              <div className="empty-chat">
                <p>Start a conversation with {selectedAgent}...</p>
                <p className="hint">Ask about relevant topics or type a question</p>
              </div>
            ) : (
              messages.map((msg, idx) => (
                <div key={idx} className={`message ${msg.role}`}>
                  <div className="message-header">
                    {msg.role === 'user' ? 'You' : msg.agent || 'Agent'}
                  </div>
                  <div className="message-content">
                    {msg.content}
                  </div>
                  {msg.metadata && (
                    <div className="message-meta">
                      {msg.metadata.routed && (
                        <span className="badge">
                          Routed to {msg.metadata.routedTo}
                        </span>
                      )}
                    </div>
                  )}
                </div>
              ))
            )}
            {loading && (
              <div className="message agent">
                <div className="message-header">Agent</div>
                <div className="message-content loading">Thinking...</div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Input */}
          <form className="message-input" onSubmit={handleSendMessage}>
            <input
              type="text"
              value={input}
              onChange={e => setInput(e.target.value)}
              placeholder="Type your message..."
              disabled={loading || !selectedAgent}
            />
            <button type="submit" disabled={loading || !selectedAgent || !input.trim()}>
              Send
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
