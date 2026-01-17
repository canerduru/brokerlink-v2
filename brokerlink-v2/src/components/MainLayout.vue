<script setup lang="ts">
import Sidebar from '../components/Sidebar.vue'
import MobileNav from '../components/MobileNav.vue'
</script>

<template>
  <div class="min-h-screen bg-gray-50 flex">
    <!-- Desktop Sidebar -->
    <Sidebar />
    
    <!-- Main Content -->
    <div class="flex-1 md:ml-64">
      <div class="min-h-screen pb-16 md:pb-0">
        <slot />
      </div>
    </div>

    <!-- Mobile Bottom Navigation -->
    <MobileNav />
  </div>
</template>
