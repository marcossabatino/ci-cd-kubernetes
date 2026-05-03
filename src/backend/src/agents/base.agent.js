class BaseAgent {
  constructor({ name, description, keywords }) {
    this.name = name;
    this.description = description;
    this.keywords = keywords;
    this.status = 'active';
  }

  async process(message, context = []) {
    throw new Error(`Agent ${this.name} must implement process()`);
  }

  calculateRelevance(message) {
    const lowerMessage = message.toLowerCase();
    const matches = this.keywords.filter(kw => lowerMessage.includes(kw.toLowerCase()));
    return matches.length > 0 ? matches.length / this.keywords.length : 0;
  }

  formatResponse(content, metadata = {}) {
    return {
      agent: this.name,
      content,
      timestamp: new Date().toISOString(),
      metadata
    };
  }

  getInfo() {
    return {
      name: this.name,
      description: this.description,
      status: this.status,
      keywords: this.keywords
    };
  }
}

export default BaseAgent;
