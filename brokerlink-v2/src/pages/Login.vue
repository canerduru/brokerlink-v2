<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const router = useRouter()

const authMode = ref<'login' | 'register'>('login')
const email = ref('')
const password = ref('')
const name = ref('')

async function handleSubmit() {
  try {
    if (authMode.value === 'login') {
      await authStore.signIn(email.value, password.value)
    } else {
      await authStore.signUp(email.value, password.value, name.value)
    }
    router.push('/')
  } catch (error) {
    console.error('Auth error:', error)
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 p-4">
    <div class="bg-white rounded-3xl shadow-xl w-full max-w-md p-8 border border-gray-100">
      <div class="text-center mb-8">
        <div class="w-16 h-16 bg-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg shadow-blue-200">
          <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4">
            </path>
          </svg>
        </div>
        <h1 class="text-2xl font-bold text-gray-900">BrokerLink'e Hoşgeldiniz</h1>
        <p class="text-gray-500 mt-2">Profesyonel Emlak Ağı</p>
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div v-if="authMode === 'register'">
          <label class="block text-sm font-medium text-gray-700 mb-1">Ad Soyad</label>
          <input 
            type="text" 
            v-model="name"
            class="w-full bg-gray-50 border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:border-blue-500 transition-colors"
            placeholder="Ahmet Yılmaz"
          >
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">E-posta</label>
          <input 
            type="email" 
            v-model="email"
            required
            class="w-full bg-gray-50 border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:border-blue-500 transition-colors"
            placeholder="ornek@email.com"
          >
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Şifre</label>
          <input 
            type="password" 
            v-model="password"
            required
            class="w-full bg-gray-50 border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:border-blue-500 transition-colors"
            placeholder="••••••••"
          >
        </div>

        <div v-if="authStore.error" class="text-red-500 text-sm bg-red-50 p-3 rounded-lg">
          {{ authStore.error }}
        </div>

        <button 
          type="submit"
          :disabled="authStore.loading"
          class="w-full bg-blue-600 text-white font-bold py-3.5 rounded-xl hover:bg-blue-700 transition-colors shadow-lg shadow-blue-200 flex items-center justify-center gap-2"
        >
          <span v-if="authStore.loading" class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></span>
          <span>{{ authMode === 'login' ? 'Giriş Yap' : 'Kayıt Ol' }}</span>
        </button>
      </form>

      <div class="mt-6 text-center">
        <p class="text-sm text-gray-500">
          <span>{{ authMode === 'login' ? 'Hesabınız yok mu?' : 'Zaten hesabınız var mı?' }}</span>
          <button 
            @click="authMode = authMode === 'login' ? 'register' : 'login'"
            class="text-blue-600 font-bold hover:underline ml-1"
          >
            {{ authMode === 'login' ? 'Kayıt Ol' : 'Giriş Yap' }}
          </button>
        </p>
      </div>
    </div>
  </div>
</template>
