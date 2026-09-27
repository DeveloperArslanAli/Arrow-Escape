/**
 * Arrow Escape — Interactive Web Game Demo & Play Simulator
 * Simulates core multi-segment arrow mechanics, slither escape, bonk recoil,
 * dynamic audio synthesizer chimes, and auto-play walkthrough animation.
 */

class ArrowGameDemo {
  constructor(canvasId) {
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) return;
    this.ctx = this.canvas.getContext('2d');

    // Grid Dimensions
    this.cols = 5;
    this.rows = 5;
    this.padding = 24;
    this.cellSize = 0;

    // Game State
    this.lives = 3;
    this.maxLives = 3;
    this.streak = 0;
    this.level = 1;
    this.arrows = [];
    this.particles = [];
    this.isAutoPlaying = false;
    this.autoPlayInterval = null;
    this.activeTweenArrows = [];

    // Audio Context (Web Audio API Procedural Tone Generator)
    this.audioCtx = null;

    this.initBoard();
    this.setupListeners();
    this.resizeCanvas();
    this.startRenderLoop();
  }

  initAudio() {
    if (!this.audioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (AudioContext) {
        this.audioCtx = new AudioContext();
      }
    }
    if (this.audioCtx && this.audioCtx.state === 'suspended') {
      this.audioCtx.resume();
    }
  }

  playChime(pitchMultiplier = 1) {
    if (!this.audioCtx) return;
    try {
      const osc = this.audioCtx.createOscillator();
      const gain = this.audioCtx.createGain();
      const now = this.audioCtx.currentTime;

      osc.type = 'sine';
      osc.frequency.setValueAtTime(440 * pitchMultiplier, now);
      osc.frequency.exponentialRampToValueAtTime(880 * pitchMultiplier, now + 0.15);

      gain.gain.setValueAtTime(0.2, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.3);

      osc.connect(gain);
      gain.connect(this.audioCtx.destination);

      osc.start(now);
      osc.stop(now + 0.35);
    } catch (e) {
      // Audio autoplay policy fallback
    }
  }

  playBonk() {
    if (!this.audioCtx) return;
    try {
      const osc = this.audioCtx.createOscillator();
      const gain = this.audioCtx.createGain();
      const now = this.audioCtx.currentTime;

      osc.type = 'triangle';
      osc.frequency.setValueAtTime(140, now);
      osc.frequency.exponentialRampToValueAtTime(60, now + 0.18);

      gain.gain.setValueAtTime(0.3, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.2);

      osc.connect(gain);
      gain.connect(this.audioCtx.destination);

      osc.start(now);
      osc.stop(now + 0.22);
    } catch (e) {}
  }

  initBoard() {
    this.lives = 3;
    this.streak = 0;
    this.updateHUD();

    // 5x5 Curated Tutorial / Interactive Layout with guaranteed solvability
    this.arrows = [
      { id: 1, c: 0, r: 0, dir: 'DOWN', path: [[0, 0], [0, 1]], color: '#38BDF8', escaping: false, bonking: 0 },
      { id: 2, c: 1, r: 0, dir: 'RIGHT', path: [[1, 0], [2, 0]], color: '#FB7185', escaping: false, bonking: 0 },
      { id: 3, c: 4, r: 0, dir: 'DOWN', path: [[4, 0], [4, 1]], color: '#F59E0B', escaping: false, bonking: 0 },
      { id: 4, c: 2, r: 1, dir: 'UP', path: [[2, 1], [2, 0]], color: '#34D399', escaping: false, bonking: 0 },
      { id: 5, c: 3, r: 1, dir: 'RIGHT', path: [[3, 1], [4, 1]], color: '#A855F7', escaping: false, bonking: 0 },
      { id: 6, c: 0, r: 3, dir: 'LEFT', path: [[1, 3], [0, 3]], color: '#38BDF8', escaping: false, bonking: 0 },
      { id: 7, c: 3, r: 3, dir: 'DOWN', path: [[3, 2], [3, 3]], color: '#FB7185', escaping: false, bonking: 0 },
      { id: 8, c: 2, r: 4, dir: 'DOWN', path: [[2, 3], [2, 4]], color: '#F59E0B', escaping: false, bonking: 0 },
      { id: 9, c: 4, r: 4, dir: 'RIGHT', path: [[3, 4], [4, 4]], color: '#34D399', escaping: false, bonking: 0 }
    ];
  }

  resizeCanvas() {
    const parent = this.canvas.parentElement;
    const size = Math.min(parent.clientWidth - 64, 420);
    this.canvas.width = size;
    this.canvas.height = size;
    this.cellSize = (size - this.padding * 2) / this.cols;
  }

  setupListeners() {
    window.addEventListener('resize', () => this.resizeCanvas());

    this.canvas.addEventListener('click', (e) => {
      this.initAudio();
      const rect = this.canvas.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      this.handleTap(x, y);
    });

    // Control buttons
    const resetBtn = document.getElementById('demoResetBtn');
    if (resetBtn) resetBtn.addEventListener('click', () => this.reset());

    const autoBtn = document.getElementById('demoAutoBtn');
    if (autoBtn) autoBtn.addEventListener('click', () => this.toggleAutoPlay());

    const hintBtn = document.getElementById('demoHintBtn');
    if (hintBtn) hintBtn.addEventListener('click', () => this.showHint());
  }

  getGridCoord(x, y) {
    const c = Math.floor((x - this.padding) / this.cellSize);
    const r = Math.floor((y - this.padding) / this.cellSize);
    if (c >= 0 && c < this.cols && r >= 0 && r < this.rows) {
      return { c, r };
    }
    return null;
  }

  handleTap(x, y) {
    const coord = this.getGridCoord(x, y);
    if (!coord) return;

    // Find arrow occupying this coordinate
    const target = this.arrows.find(a => 
      !a.escaping && a.path.some(pt => pt[0] === coord.c && pt[1] === coord.r)
    );

    if (target) {
      this.attemptEscape(target);
    }
  }

  isPathClear(arrow) {
    const head = arrow.path[arrow.path.length - 1];
    let dc = 0, dr = 0;
    if (arrow.dir === 'UP') dr = -1;
    if (arrow.dir === 'DOWN') dr = 1;
    if (arrow.dir === 'LEFT') dc = -1;
    if (arrow.dir === 'RIGHT') dc = 1;

    let checkC = head[0] + dc;
    let checkR = head[1] + dr;

    while (checkC >= 0 && checkC < this.cols && checkR >= 0 && checkR < this.rows) {
      // Check collision against any active arrow
      const blocked = this.arrows.some(other => 
        other.id !== arrow.id && !other.escaping &&
        other.path.some(pt => pt[0] === checkC && pt[1] === checkR)
      );
      if (blocked) return false;
      checkC += dc;
      checkR += dr;
    }
    return true;
  }

  attemptEscape(arrow) {
    if (this.isPathClear(arrow)) {
      // Successful Escape!
      arrow.escaping = true;
      this.streak++;
      const pitch = Math.pow(1.12, Math.min(this.streak, 8));
      this.playChime(pitch);

      // Spawn celebration particles
      const head = arrow.path[arrow.path.length - 1];
      const px = this.padding + (head[0] + 0.5) * this.cellSize;
      const py = this.padding + (head[1] + 0.5) * this.cellSize;
      this.spawnParticles(px, py, arrow.color);

      // Animate slither offset
      let progress = 0;
      const animateEscape = () => {
        progress += 0.08;
        arrow.escapeProgress = progress;
        if (progress < 1) {
          requestAnimationFrame(animateEscape);
        } else {
          // Remove from board
          this.arrows = this.arrows.filter(a => a.id !== arrow.id);
          this.checkVictory();
        }
      };
      animateEscape();
    } else {
      // Obstructed -> Elastic Bonk Recoil & Lose Heart
      this.streak = 0;
      this.lives = Math.max(0, this.lives - 1);
      this.playBonk();

      // Trigger elastic bounce
      arrow.bonking = 1;
      let bonkFrames = 0;
      const animateBonk = () => {
        bonkFrames++;
        arrow.bonking = Math.sin(bonkFrames * 0.8) * Math.exp(-bonkFrames * 0.15) * 8;
        if (bonkFrames < 16) {
          requestAnimationFrame(animateBonk);
        } else {
          arrow.bonking = 0;
        }
      };
      animateBonk();

      if (this.lives === 0) {
        setTimeout(() => {
          alert('Out of Hearts! Tap Reset to try again.');
          this.reset();
        }, 300);
      }
    }
    this.updateHUD();
  }

  checkVictory() {
    if (this.arrows.length === 0) {
      this.playChime(1.5);
      setTimeout(() => {
        alert('🎉 Level Cleared! All arrows escaped cleanly!');
        this.reset();
      }, 300);
    }
  }

  showHint() {
    const solvable = this.arrows.find(a => !a.escaping && this.isPathClear(a));
    if (solvable) {
      solvable.isHinted = true;
      setTimeout(() => { solvable.isHinted = false; }, 1500);
    }
  }

  toggleAutoPlay() {
    this.initAudio();
    this.isAutoPlaying = !this.isAutoPlaying;
    const btn = document.getElementById('demoAutoBtn');
    if (btn) btn.classList.toggle('active', this.isAutoPlaying);

    if (this.isAutoPlaying) {
      this.autoPlayInterval = setInterval(() => {
        if (!this.isAutoPlaying) return;
        const valid = this.arrows.find(a => !a.escaping && this.isPathClear(a));
        if (valid) {
          this.attemptEscape(valid);
        } else if (this.arrows.length === 0) {
          this.reset();
        }
      }, 800);
    } else {
      clearInterval(this.autoPlayInterval);
    }
  }

  reset() {
    if (this.autoPlayInterval) clearInterval(this.autoPlayInterval);
    this.isAutoPlaying = false;
    const btn = document.getElementById('demoAutoBtn');
    if (btn) btn.classList.remove('active');
    this.initBoard();
  }

  spawnParticles(x, y, color) {
    for (let i = 0; i < 16; i++) {
      const angle = Math.random() * Math.PI * 2;
      const speed = 2 + Math.random() * 4;
      this.particles.push({
        x, y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        alpha: 1,
        color,
        size: 3 + Math.random() * 3
      });
    }
  }

  updateHUD() {
    const livesEl = document.getElementById('demoLives');
    if (livesEl) {
      let heartsHtml = '';
      for (let i = 0; i < this.maxLives; i++) {
        heartsHtml += i < this.lives ? '❤️ ' : '🖤 ';
      }
      livesEl.innerHTML = heartsHtml;
    }

    const streakEl = document.getElementById('demoStreak');
    if (streakEl) {
      streakEl.innerText = this.streak > 1 ? `Combo ×${this.streak}` : '';
    }
  }

  startRenderLoop() {
    const render = () => {
      this.draw();
      requestAnimationFrame(render);
    };
    render();
  }

  draw() {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    // 1. Draw Grid Lines
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.06)';
    ctx.lineWidth = 1;
    for (let c = 0; c <= this.cols; c++) {
      const x = this.padding + c * this.cellSize;
      ctx.beginPath();
      ctx.moveTo(x, this.padding);
      ctx.lineTo(x, this.canvas.height - this.padding);
      ctx.stroke();
    }
    for (let r = 0; r <= this.rows; r++) {
      const y = this.padding + r * this.cellSize;
      ctx.beginPath();
      ctx.moveTo(this.padding, y);
      ctx.lineTo(this.canvas.width - this.padding, y);
      ctx.stroke();
    }

    // 2. Draw Arrows
    this.arrows.forEach(arrow => {
      this.drawArrow(arrow);
    });

    // 3. Draw Particles
    for (let i = this.particles.length - 1; i >= 0; i--) {
      const p = this.particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.alpha -= 0.025;
      if (p.alpha <= 0) {
        this.particles.splice(i, 1);
      } else {
        ctx.fillStyle = p.color;
        ctx.globalAlpha = p.alpha;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fill();
        ctx.globalAlpha = 1;
      }
    }
  }

  drawArrow(arrow) {
    const ctx = this.ctx;
    const pts = arrow.path;
    if (pts.length < 2) return;

    let offsetX = 0;
    let offsetY = 0;

    // Bonk recoil offset
    if (arrow.bonking) {
      if (arrow.dir === 'UP') offsetY -= arrow.bonking;
      if (arrow.dir === 'DOWN') offsetY += arrow.bonking;
      if (arrow.dir === 'LEFT') offsetX -= arrow.bonking;
      if (arrow.dir === 'RIGHT') offsetX += arrow.bonking;
    }

    // Escape slither offset
    if (arrow.escaping && arrow.escapeProgress) {
      const distance = arrow.escapeProgress * 300;
      if (arrow.dir === 'UP') offsetY -= distance;
      if (arrow.dir === 'DOWN') offsetY += distance;
      if (arrow.dir === 'LEFT') offsetX -= distance;
      if (arrow.dir === 'RIGHT') offsetX += distance;
    }

    ctx.save();
    ctx.translate(offsetX, offsetY);

    // Glowing outline if hinted
    if (arrow.isHinted) {
      ctx.shadowColor = '#FDE047';
      ctx.shadowBlur = 18;
    }

    // Draw Polyline Body
    ctx.strokeStyle = arrow.color;
    ctx.lineWidth = this.cellSize * 0.45;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    ctx.beginPath();
    pts.forEach((pt, idx) => {
      const px = this.padding + (pt[0] + 0.5) * this.cellSize;
      const py = this.padding + (pt[1] + 0.5) * this.cellSize;
      if (idx === 0) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    });
    ctx.stroke();

    // Draw Arrowhead
    const headPt = pts[pts.length - 1];
    const hx = this.padding + (headPt[0] + 0.5) * this.cellSize;
    const hy = this.padding + (headPt[1] + 0.5) * this.cellSize;

    let angle = 0;
    if (arrow.dir === 'RIGHT') angle = 0;
    if (arrow.dir === 'DOWN') angle = Math.PI / 2;
    if (arrow.dir === 'LEFT') angle = Math.PI;
    if (arrow.dir === 'UP') angle = -Math.PI / 2;

    ctx.save();
    ctx.translate(hx, hy);
    ctx.rotate(angle);

    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.moveTo(this.cellSize * 0.35, 0);
    ctx.lineTo(-this.cellSize * 0.2, -this.cellSize * 0.25);
    ctx.lineTo(-this.cellSize * 0.2, this.cellSize * 0.25);
    ctx.closePath();
    ctx.fill();

    ctx.restore();
    ctx.restore();
  }
}

// Initialize when DOM loads
document.addEventListener('DOMContentLoaded', () => {
  window.arrowDemo = new ArrowGameDemo('puzzleCanvas');
});
