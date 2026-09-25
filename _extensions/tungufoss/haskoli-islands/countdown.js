(() => {
  const timers = new WeakMap();

  function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const rest = seconds % 60;
    return `${minutes}:${String(rest).padStart(2, "0")}`;
  }

  function ringBell() {
    const AudioContext = window.AudioContext || window.webkitAudioContext;
    if (!AudioContext) return;

    const ctx = new AudioContext();
    const now = ctx.currentTime;
    [880, 1175, 1568].forEach((frequency, index) => {
      const oscillator = ctx.createOscillator();
      const gain = ctx.createGain();
      oscillator.type = "sine";
      oscillator.frequency.setValueAtTime(frequency, now + index * 0.18);
      gain.gain.setValueAtTime(0, now + index * 0.18);
      gain.gain.linearRampToValueAtTime(0.18, now + index * 0.18 + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.001, now + index * 0.18 + 0.15);
      oscillator.connect(gain).connect(ctx.destination);
      oscillator.start(now + index * 0.18);
      oscillator.stop(now + index * 0.18 + 0.16);
    });
  }

  function stopTimer(section) {
    const timer = timers.get(section);
    if (timer) {
      window.clearInterval(timer.interval);
      timers.delete(section);
    }
  }

  function startTimer(section) {
    if (!section?.classList?.contains("countdown-break")) return;

    stopTimer(section);
    const display = section.querySelector("[data-countdown-display]");
    const status = section.querySelector("[data-countdown-status]");
    if (!display) return;

    const duration = Number(section.dataset.countdownSeconds || 300);
    const started = Date.now();
    let rang = false;

    const tick = () => {
      const elapsed = Math.floor((Date.now() - started) / 1000);
      const remaining = Math.max(0, duration - elapsed);
      display.textContent = formatTime(remaining);
      section.style.setProperty("--countdown-progress", `${(remaining / duration) * 100}%`);

      if (remaining === 0) {
        window.clearInterval(interval);
        timers.delete(section);
        section.classList.add("countdown-finished");
        if (status) status.textContent = "Pásan er búin";
        if (!rang) {
          rang = true;
          ringBell();
        }
      }
    };

    section.classList.remove("countdown-finished");
    if (status) status.textContent = "Tíminn telur niður";
    const interval = window.setInterval(tick, 250);
    timers.set(section, { interval });
    tick();
  }

  window.addEventListener("load", () => {
    if (!window.Reveal) return;
    Reveal.on("slidechanged", event => {
      stopTimer(event.previousSlide);
      startTimer(event.currentSlide);
    });
    startTimer(Reveal.getCurrentSlide());
  });
})();
