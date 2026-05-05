/* ============================================
   InviSmile - Premium Website Interactions
   ============================================ */

// ============================================
// Particle Canvas - Floating organic particles
// ============================================
class ParticleField {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.particles = [];
        this.mouse = { x: 0, y: 0 };
        this.resize();
        this.init();
        this.animate();

        window.addEventListener('resize', () => this.resize());
        window.addEventListener('mousemove', (e) => {
            this.mouse.x = e.clientX;
            this.mouse.y = e.clientY;
        });
    }

    resize() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
    }

    init() {
        const count = Math.min(80, Math.floor(window.innerWidth / 20));
        for (let i = 0; i < count; i++) {
            this.particles.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                size: Math.random() * 2 + 0.5,
                speedX: (Math.random() - 0.5) * 0.3,
                speedY: (Math.random() - 0.5) * 0.3,
                opacity: Math.random() * 0.5 + 0.1,
                color: this.getColor()
            });
        }
    }

    getColor() {
        const colors = [
            'rgba(227, 217, 198,',  // oatmeal
            'rgba(209, 166, 122,',  // caramel
            'rgba(179, 102, 76,',   // terracotta
            'rgba(180, 148, 118,',  // neutral warm
        ];
        return colors[Math.floor(Math.random() * colors.length)];
    }

    animate() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        this.particles.forEach(p => {
            p.x += p.speedX;
            p.y += p.speedY;

            // Wrap around
            if (p.x < 0) p.x = this.canvas.width;
            if (p.x > this.canvas.width) p.x = 0;
            if (p.y < 0) p.y = this.canvas.height;
            if (p.y > this.canvas.height) p.y = 0;

            // Draw
            this.ctx.beginPath();
            this.ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
            this.ctx.fillStyle = `${p.color} ${p.opacity})`;
            this.ctx.fill();
        });

        // Draw connections
        this.particles.forEach((p, i) => {
            this.particles.slice(i + 1).forEach(p2 => {
                const dx = p.x - p2.x;
                const dy = p.y - p2.y;
                const dist = Math.sqrt(dx * dx + dy * dy);
                if (dist < 120) {
                    this.ctx.beginPath();
                    this.ctx.moveTo(p.x, p.y);
                    this.ctx.lineTo(p2.x, p2.y);
                    this.ctx.strokeStyle = `rgba(180, 148, 118, ${0.05 * (1 - dist / 120)})`;
                    this.ctx.lineWidth = 0.5;
                    this.ctx.stroke();
                }
            });
        });

        requestAnimationFrame(() => this.animate());
    }
}

// ============================================
// Scroll Animations
// ============================================
class ScrollAnimator {
    constructor() {
        this.elements = document.querySelectorAll('[data-animate]');
        this.observer = new IntersectionObserver(
            (entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const delay = entry.target.dataset.delay || 0;
                        setTimeout(() => {
                            entry.target.classList.add('visible');
                        }, parseInt(delay));
                        this.observer.unobserve(entry.target);
                    }
                });
            },
            { threshold: 0.1, rootMargin: '0px 0px -50px 0px' }
        );

        this.elements.forEach(el => this.observer.observe(el));
    }
}

// ============================================
// Navigation Scroll Effect
// ============================================
class Navigation {
    constructor() {
        this.nav = document.getElementById('nav');
        this.lastScroll = 0;

        window.addEventListener('scroll', () => this.onScroll(), { passive: true });
    }

    onScroll() {
        const scroll = window.scrollY;

        if (scroll > 50) {
            this.nav.classList.add('scrolled');
        } else {
            this.nav.classList.remove('scrolled');
        }

        this.lastScroll = scroll;
    }
}

// ============================================
// Smooth Scroll for Anchor Links
// ============================================
class SmoothScroll {
    constructor() {
        document.querySelectorAll('a[href^="#"]').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const target = document.querySelector(link.getAttribute('href'));
                if (target) {
                    const offset = 80;
                    const top = target.getBoundingClientRect().top + window.scrollY - offset;
                    window.scrollTo({ top, behavior: 'smooth' });
                }
            });
        });
    }
}

// ============================================
// Ring Animation on Scroll
// ============================================
class RingAnimator {
    constructor() {
        const rings = document.querySelectorAll('.bc-progress, .chr-svg circle:nth-child(even)');
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const ring = entry.target;
                    
                    // Allow CSS transitions
                    ring.style.transition = 'stroke-dashoffset 2s cubic-bezier(0.16, 1, 0.3, 1)';
                    
                    if (ring.classList.contains('bc-progress')) {
                        const computedStyle = getComputedStyle(ring);
                        const progress = parseFloat(ring.style.getPropertyValue('--progress')) || 0;
                        const r = parseFloat(computedStyle.getPropertyValue('--r')) || ring.getAttribute('r') || 48;
                        const circumference = 2 * Math.PI * r;
                        
                        // Set start state
                        ring.style.strokeDasharray = circumference;
                        ring.style.strokeDashoffset = circumference;
                        
                        // Trigger reflow to apply start state instantly without transition
                        ring.style.transition = 'none';
                        ring.getBoundingClientRect();
                        
                        // Apply target state with transition
                        ring.style.transition = 'stroke-dashoffset 2s cubic-bezier(0.16, 1, 0.3, 1)';
                        ring.style.strokeDashoffset = circumference * (1 - progress);
                        
                    } else if (ring.hasAttribute('stroke-dasharray')) {
                        // Calendar hero rings
                        const dashArray = parseFloat(ring.getAttribute('stroke-dasharray'));
                        const targetOffset = parseFloat(ring.getAttribute('stroke-dashoffset'));
                        
                        ring.style.strokeDasharray = dashArray;
                        ring.style.strokeDashoffset = dashArray; // Empty
                        
                        ring.style.transition = 'none';
                        ring.getBoundingClientRect();
                        
                        ring.style.transition = 'stroke-dashoffset 2s cubic-bezier(0.16, 1, 0.3, 1)';
                        ring.style.strokeDashoffset = targetOffset;
                    }
                    
                    observer.unobserve(ring);
                }
            });
        }, { threshold: 0.1 });

        rings.forEach(ring => observer.observe(ring));
    }
}

// ============================================
// Counter Animation for Stats
// ============================================
class CounterAnimator {
    constructor() {
        // Animate numbers when they come into view
        const numbers = document.querySelectorAll('.streak-number');
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    this.animateValue(entry.target, 0, 14, 1200);
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.5 });

        numbers.forEach(num => observer.observe(num));
    }

    animateValue(el, start, end, duration) {
        const range = end - start;
        const startTime = performance.now();

        const update = (currentTime) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const eased = 1 - Math.pow(1 - progress, 3);
            const current = Math.round(start + range * eased);
            el.textContent = current;
            if (progress < 1) requestAnimationFrame(update);
        };

        requestAnimationFrame(update);
    }
}

// ============================================
// 3D Tilt Effect on Cards
// ============================================
class TiltEffect {
    constructor() {
        const cards = document.querySelectorAll('.feature-card, .eco-card, .glass-card, .bento-card');

        cards.forEach(card => {
            card.addEventListener('mousemove', (e) => {
                const rect = card.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                const rotateX = (y - centerY) / centerY * -3;
                const rotateY = (x - centerX) / centerX * 3;

                card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-4px)`;
            });

            card.addEventListener('mouseleave', () => {
                card.style.transform = '';
            });
        });
    }
}

// ============================================
// Initialize Everything
// ============================================
document.addEventListener('DOMContentLoaded', () => {
    // Particle background
    const canvas = document.getElementById('particleCanvas');
    if (canvas) new ParticleField(canvas);

    // Scroll animations
    new ScrollAnimator();

    // Navigation
    new Navigation();

    // Smooth scroll
    new SmoothScroll();

    // Ring animations
    new RingAnimator();

    // Counter animations
    new CounterAnimator();

    // 3D tilt
    new TiltEffect();

    // Live Timer for Active Session
    new LiveTimer();
});

// ============================================
// Live Timer Simulation
// ============================================
class LiveTimer {
    constructor() {
        this.groups = new Map();

        document.querySelectorAll('[data-live-counter-group]').forEach((el) => {
            const groupName = el.dataset.liveCounterGroup;
            if (!groupName) return;

            const existing = this.groups.get(groupName);
            if (existing) {
                existing.elements.push(el);
                return;
            }

            this.groups.set(groupName, {
                elapsedSeconds: this.parseTimeToSeconds(el.textContent.trim()),
                elements: [el]
            });
        });

        if (!this.groups.size) return;

        this.render();
        setInterval(() => this.tick(), 1000);
    }

    parseTimeToSeconds(timeText) {
        const [minutesText, secondsText] = timeText.split(':');
        const minutes = Number.parseInt(minutesText, 10);
        const seconds = Number.parseInt(secondsText, 10);

        if (Number.isNaN(minutes) || Number.isNaN(seconds)) {
            return 0;
        }

        return (minutes * 60) + seconds;
    }

    formatTime(totalSeconds) {
        const minutes = Math.floor(totalSeconds / 60);
        const seconds = totalSeconds % 60;
        return `${minutes}:${seconds.toString().padStart(2, '0')}`;
    }

    render() {
        this.groups.forEach((group) => {
            const formattedTime = this.formatTime(group.elapsedSeconds);
            group.elements.forEach((el) => {
                el.textContent = formattedTime;
            });
        });
    }

    tick() {
        this.groups.forEach((group) => {
            group.elapsedSeconds += 1;
        });

        this.render();
    }
}
