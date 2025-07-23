<template>
  <div class="particles-container" ref="partic" :style="containerStyle">
    <div v-for="particle in particles" :key="particle.id" class="particle" :style="particle.style"
      @animationend="removeParticle(particle.id)">
      <div class="circle"></div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue';

const particles = ref([]);
const spawnInterval = 500;

const containerHeight = ref(0);
const containerStyle = ref({ height: '0px', '--translate-y': '0px' });

let spawnTimer = null;

const updateContainerHeight = () => {
  const height = document.documentElement.scrollHeight;
  containerHeight.value = height;
  containerStyle.value = {
    height: `${height}px`,
    '--translate-y': `${height}px`
  };
};

const startSpawning = () => {
  if (!spawnTimer) {
    spawnTimer = setInterval(addParticle, spawnInterval);
  }
};

const stopSpawning = () => {
  if (spawnTimer) {
    clearInterval(spawnTimer);
    spawnTimer = null;
  }
};

const handleVisibilityChange = () => document.visibilityState === 'visible' ? startSpawning() : stopSpawning()

function getParticleStyle() {
  const size = Math.random() * 7 + 3 + 'px';
  const left = Math.random() * 100 + '%';
  const normalizedHeight = Math.min(containerHeight.value, 1200);
  const moveDuration = (normalizedHeight / 20) + 10 + 's';

  const opacity = Math.random() * 0.5 + 0.5;

  return { width: size, height: size, left: left, '--move-duration': moveDuration, opacity: opacity };
}

function addParticle() {
  let particleId = Math.floor(Math.random() * 1000000000);

  particles.value.push({ id: particleId, style: getParticleStyle() });
}

function removeParticle(id) {
  particles.value = particles.value.filter(particle => particle.id !== id);
}

onMounted(() => {
  updateContainerHeight();
  window.addEventListener('resize', updateContainerHeight);
  document.addEventListener('visibilitychange', handleVisibilityChange);
  startSpawning();
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', updateContainerHeight);
  document.removeEventListener('visibilitychange', handleVisibilityChange);
  stopSpawning();
});
</script>

<style scoped>
.particles-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  pointer-events: none;
  overflow: hidden;
  background: transparent;
  z-index: 20;
}

.particle {
  position: absolute;
  top: 0px;
  border-radius: 50%;
  animation: moveDown var(--move-duration);
}


.circle {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  mix-blend-mode: screen;
  background-image: radial-gradient(#99ffff,
      #99ffff 10%,
      hsla(180, 100%, 80%, 0) 56%);
  animation: fadeIn 200ms ease-in-out infinite, scaleFrames 2s ease-in-out infinite;
}

@keyframes moveDown {
  from {
    transform: translateY(0);
  }

  to {
    transform: translateY(var(--translate-y));
  }
}


@keyframes fadeIn {
  0% {
    opacity: 1;
  }

  50% {
    opacity: 0.7;
  }

  100% {
    opacity: 1;
  }
}

@keyframes scaleFrames {
  0% {
    transform: scale(0.4);
  }

  50% {
    transform: scale(2.2);
  }

  100% {
    transform: scale(0.4);
  }
}
</style>