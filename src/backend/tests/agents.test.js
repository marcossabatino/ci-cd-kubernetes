import BaseAgent from '../src/agents/base.agent.js';
import OrchestratorAgent from '../src/agents/orchestrator.agent.js';
import KubernetesAgent from '../src/agents/kubernetes.agent.js';
import TerraformAgent from '../src/agents/terraform.agent.js';
import HealthAgent from '../src/agents/health.agent.js';

describe('Agent System', () => {
  describe('BaseAgent', () => {
    test('should initialize with name, description, keywords', () => {
      const agent = new BaseAgent({
        name: 'test',
        description: 'Test agent',
        keywords: ['test']
      });

      expect(agent.name).toBe('test');
      expect(agent.description).toBe('Test agent');
      expect(agent.keywords).toContain('test');
    });

    test('should calculate relevance based on keywords', () => {
      const agent = new BaseAgent({
        name: 'test',
        description: 'Test agent',
        keywords: ['kubernetes', 'pod', 'deployment']
      });

      const relevance = agent.calculateRelevance('how to create a kubernetes pod');
      expect(relevance).toBeGreaterThan(0);
    });

    test('should format response correctly', () => {
      const agent = new BaseAgent({
        name: 'test',
        description: 'Test agent',
        keywords: []
      });

      const response = agent.formatResponse('test content', { meta: 'data' });
      expect(response).toHaveProperty('agent');
      expect(response).toHaveProperty('content');
      expect(response).toHaveProperty('timestamp');
      expect(response).toHaveProperty('metadata');
    });
  });

  describe('OrchestratorAgent', () => {
    test('should register agents', () => {
      const orchestrator = new OrchestratorAgent();
      const kubeAgent = new KubernetesAgent();

      orchestrator.registerAgent(kubeAgent);
      expect(orchestrator.agents.has('kubernetes')).toBe(true);
    });

    test('should route to kubernetes agent for relevant message', async () => {
      const orchestrator = new OrchestratorAgent();
      orchestrator.registerAgent(new KubernetesAgent());

      const response = await orchestrator.process('how do I create a pod?');
      expect(response.metadata.routed).toBe(true);
      expect(response.metadata.routedTo).toBe('kubernetes');
    });
  });

  describe('KubernetesAgent', () => {
    test('should respond to kubernetes keywords', async () => {
      const agent = new KubernetesAgent();
      const relevance = agent.calculateRelevance('kubectl deployment');
      expect(relevance).toBeGreaterThan(0);
    });

    test('should provide deployment guidance', async () => {
      const agent = new KubernetesAgent();
      const response = await agent.process('tell me about deployment');
      expect(response.content).toContain('Deployment');
    });
  });

  describe('TerraformAgent', () => {
    test('should respond to terraform keywords', () => {
      const agent = new TerraformAgent();
      const relevance = agent.calculateRelevance('terraform state');
      expect(relevance).toBeGreaterThan(0);
    });

    test('should provide terraform guidance', async () => {
      const agent = new TerraformAgent();
      const response = await agent.process('how to manage state');
      expect(response.content).toContain('state');
    });
  });

  describe('HealthAgent', () => {
    test('should provide health metrics', () => {
      const agent = new HealthAgent();
      const metrics = agent.getHealthMetrics();

      expect(metrics).toHaveProperty('status');
      expect(metrics).toHaveProperty('uptime_seconds');
      expect(metrics.status).toBe('healthy');
    });
  });
});
