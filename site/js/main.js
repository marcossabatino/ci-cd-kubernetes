// ========================================
// Observability Portal — Main JavaScript
// ========================================

/**
 * Theme Toggle (Light/Dark Mode)
 */
function initThemeToggle() {
  const themeToggle = document.getElementById('themeToggle');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const savedTheme = localStorage.getItem('theme');

  // Set initial theme
  const theme = savedTheme || (prefersDark ? 'dark' : 'light');
  applyTheme(theme);

  // Toggle on button click
  themeToggle?.addEventListener('click', () => {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    applyTheme(newTheme);
    localStorage.setItem('theme', newTheme);
  });

  // Listen to system preference changes
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
    if (!localStorage.getItem('theme')) {
      applyTheme(e.matches ? 'dark' : 'light');
    }
  });
}

function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  const themeToggle = document.getElementById('themeToggle');
  if (themeToggle) {
    themeToggle.textContent = theme === 'dark' ? '☀️' : '🌙';
  }
}

/**
 * Smooth Scrolling
 */
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({ behavior: 'smooth' });
      }
    });
  });
}

/**
 * Active Navigation Link
 */
function updateActiveNavLink() {
  const currentPath = window.location.pathname;
  document.querySelectorAll('.nav-links a').forEach(link => {
    const href = link.getAttribute('href');
    if (href === currentPath || (currentPath === '/' && href === '/')) {
      link.classList.add('active');
    } else {
      link.classList.remove('active');
    }
  });
}

/**
 * Intersection Observer for animations
 */
function initObserver() {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '1';
        entry.target.style.transform = 'translateY(0)';
      }
    });
  }, { threshold: 0.1 });

  document.querySelectorAll('.content-section, .pillar-card, .signal-card, .tool-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
  });
}

/**
 * Copy to clipboard (for code blocks)
 */
function initCodeCopy() {
  document.querySelectorAll('.code-block').forEach(block => {
    const pre = block.querySelector('pre');
    if (pre) {
      const button = document.createElement('button');
      button.className = 'copy-btn';
      button.textContent = 'Copy';
      button.style.cssText = `
        position: absolute;
        top: 10px;
        right: 10px;
        background: #667eea;
        color: white;
        border: none;
        padding: 8px 12px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 12px;
      `;

      block.style.position = 'relative';
      block.appendChild(button);

      button.addEventListener('click', () => {
        const text = pre.textContent;
        navigator.clipboard.writeText(text).then(() => {
          button.textContent = 'Copied!';
          setTimeout(() => { button.textContent = 'Copy'; }, 2000);
        });
      });
    }
  });
}

/**
 * Performance metrics (if needed for observability demo)
 */
function trackPageMetrics() {
  if (window.performance && window.performance.timing) {
    window.addEventListener('load', () => {
      const timing = window.performance.timing;
      const navigationStart = timing.navigationStart;
      const loadTime = timing.loadEventEnd - navigationStart;
      const domContentLoadedTime = timing.domContentLoadedEventEnd - navigationStart;

      console.log({
        page: window.location.pathname,
        loadTime: loadTime + 'ms',
        domContentLoadedTime: domContentLoadedTime + 'ms',
        timestamp: new Date().toISOString()
      });
    });
  }
}

/**
 * Initialize all
 */
document.addEventListener('DOMContentLoaded', () => {
  initThemeToggle();
  initSmoothScroll();
  updateActiveNavLink();
  initObserver();
  initCodeCopy();
  trackPageMetrics();

  // Log that page loaded
  console.log('🎉 Observability Portal loaded successfully');
});

// Log navigation
window.addEventListener('beforeunload', () => {
  console.log('📊 User leaving page:', window.location.pathname);
});
