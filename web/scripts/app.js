/**
 * Arrow Escape — Web Application Main Controller
 * Handles scroll-driven storytelling, interactive navigation,
 * 8-Worlds palette inspector, modals, and responsive interactions.
 */

document.addEventListener('DOMContentLoaded', () => {
  initHeaderScroll();
  initMobileMenu();
  initScrollAnimations();
  initStorytellingSteps();
  initWorldsInspector();
  initContactForm();
  initModals();
});

// 1. Sticky Header Blur on Scroll
function initHeaderScroll() {
  const header = document.querySelector('.site-header');
  window.addEventListener('scroll', () => {
    if (window.scrollY > 40) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }
  });
}

// 2. Mobile Menu Toggle
function initMobileMenu() {
  const menuBtn = document.querySelector('.mobile-menu-btn');
  const navLinks = document.querySelector('.nav-links');
  if (!menuBtn || !navLinks) return;

  menuBtn.addEventListener('click', () => {
    const isOpen = navLinks.style.display === 'flex';
    navLinks.style.display = isOpen ? 'none' : 'flex';
    if (!isOpen) {
      navLinks.style.flexDirection = 'column';
      navLinks.style.position = 'absolute';
      navLinks.style.top = '70px';
      navLinks.style.left = '0';
      navLinks.style.width = '100%';
      navLinks.style.background = '#0E131F';
      navLinks.style.padding = '24px';
      navLinks.style.borderBottom = '1px solid rgba(255,255,255,0.1)';
    }
  });

  // Close menu when clicking link
  document.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', () => {
      if (window.innerWidth <= 768) {
        navLinks.style.display = 'none';
      }
    });
  });
}

// 3. Scroll-Driven Storytelling Animations (IntersectionObserver)
function initScrollAnimations() {
  const animatedElements = document.querySelectorAll('.animate-on-scroll');
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.15 });

  animatedElements.forEach(el => observer.observe(el));
}

// 4. Interactive Storytelling Steps
function initStorytellingSteps() {
  const stepCards = document.querySelectorAll('.step-card');
  stepCards.forEach((card, idx) => {
    card.addEventListener('click', () => {
      stepCards.forEach(c => c.classList.remove('active'));
      card.classList.add('active');

      // Trigger demo actions based on step
      if (window.arrowDemo) {
        if (idx === 0) {
          window.arrowDemo.reset();
        } else if (idx === 1) {
          window.arrowDemo.showHint();
        } else if (idx === 2) {
          // Trigger first escape
          const valid = window.arrowDemo.arrows.find(a => window.arrowDemo.isPathClear(a));
          if (valid) window.arrowDemo.attemptEscape(valid);
        } else if (idx === 3) {
          window.arrowDemo.toggleAutoPlay();
        }
      }
    });
  });
}

// 5. 8-Worlds Interactive Theme Inspector
function initWorldsInspector() {
  const worldCards = document.querySelectorAll('.world-card');
  worldCards.forEach(card => {
    card.addEventListener('mouseenter', () => {
      const color = card.style.getPropertyValue('--world-color') || '#38BDF8';
      card.style.borderColor = color;
      card.style.boxShadow = `0 12px 30px -10px ${color}40`;
    });
    card.addEventListener('mouseleave', () => {
      card.style.borderColor = 'rgba(255, 255, 255, 0.08)';
      card.style.boxShadow = 'none';
    });
  });
}

// 6. Contact Form Handler
function initContactForm() {
  const form = document.getElementById('contactForm');
  if (!form) return;

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalText = submitBtn.innerText;

    submitBtn.innerText = 'Sending Message...';
    submitBtn.disabled = true;

    setTimeout(() => {
      submitBtn.innerText = '✓ Message Sent Successfully!';
      submitBtn.style.background = 'var(--grad-emerald)';
      form.reset();

      setTimeout(() => {
        submitBtn.innerText = originalText;
        submitBtn.style.background = 'var(--grad-primary)';
        submitBtn.disabled = false;
      }, 3000);
    }, 1000);
  });
}

// 7. Modals (Privacy Policy & Terms)
function initModals() {
  const privacyModal = document.getElementById('privacyModal');
  const termsModal = document.getElementById('termsModal');

  // Triggers
  document.querySelectorAll('[data-open-privacy]').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      openModal(privacyModal);
    });
  });

  document.querySelectorAll('[data-open-terms]').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      openModal(termsModal);
    });
  });

  // Closers
  document.querySelectorAll('.modal-close-btn, .modal-overlay').forEach(el => {
    el.addEventListener('click', (e) => {
      if (e.target === el || e.target.classList.contains('modal-close-btn')) {
        closeAllModals();
      }
    });
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeAllModals();
  });

  function openModal(modal) {
    if (!modal) return;
    document.body.style.overflow = 'hidden';
    modal.classList.add('active');
  }

  function closeAllModals() {
    document.body.style.overflow = '';
    document.querySelectorAll('.modal-overlay').forEach(m => m.classList.remove('active'));
  }
}
