import BaseAgent from './base.agent.js';

class OrchestratorAgent extends BaseAgent {
  constructor() {
    super({
      name: 'orchestrator',
      description: 'Routes messages to the most relevant specialist agent',
      keywords: ['what', 'how', 'which', 'help', 'explain']
    });
    this.agents = new Map();
  }

  registerAgent(agent) {
    this.agents.set(agent.name, agent);
  }

  async process(message, context = []) {
    const scores = new Map();

    for (const [name, agent] of this.agents) {
      if (name === 'orchestrator') continue;
      const score = agent.calculateRelevance(message);
      if (score > 0) {
        scores.set(name, score);
      }
    }

    if (scores.size === 0) {
      return this.formatResponse(
        'I could not determine which agent to route this to. Available agents: ' +
        Array.from(this.agents.keys())
          .filter(name => name !== 'orchestrator')
          .join(', '),
        { routed: false }
      );
    }

    const bestMatch = Array.from(scores.entries())
      .sort((a, b) => b[1] - a[1])[0][0];

    const agent = this.agents.get(bestMatch);
    const agentResponse = await agent.process(message, context);

    return this.formatResponse(
      agentResponse.content,
      {
        routed: true,
        routedTo: bestMatch,
        relevanceScore: scores.get(bestMatch),
        originalAgent: agentResponse.agent
      }
    );
  }

  getAvailableAgents() {
    return Array.from(this.agents.values())
      .filter(agent => agent.name !== 'orchestrator')
      .map(agent => agent.getInfo());
  }
}

export default OrchestratorAgent;
