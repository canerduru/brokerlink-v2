import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '../lib/supabase'
import type { User } from '@supabase/supabase-js'

export const useAuthStore = defineStore('auth', () => {
    const user = ref<User | null>(null)
    const loading = ref(false)
    const error = ref<string | null>(null)

    const isAuthenticated = computed(() => !!user.value)

    async function initialize() {
        const { data: { session } } = await supabase.auth.getSession()
        user.value = session?.user || null

        supabase.auth.onAuthStateChange((_event, session) => {
            user.value = session?.user || null
        })
    }

    async function signIn(email: string, password: string) {
        loading.value = true
        error.value = null

        const { data, error: signInError } = await supabase.auth.signInWithPassword({
            email,
            password,
        })

        if (signInError) {
            error.value = signInError.message
            loading.value = false
            throw signInError
        }

        user.value = data.user
        loading.value = false
        return data
    }

    async function signUp(email: string, password: string, name: string) {
        loading.value = true
        error.value = null

        const { data, error: signUpError } = await supabase.auth.signUp({
            email,
            password,
            options: {
                data: {
                    name,
                },
            },
        })

        if (signUpError) {
            error.value = signUpError.message
            loading.value = false
            throw signUpError
        }

        user.value = data.user
        loading.value = false
        return data
    }

    async function signOut() {
        loading.value = true
        await supabase.auth.signOut()
        user.value = null
        loading.value = false
    }

    return {
        user,
        loading,
        error,
        isAuthenticated,
        initialize,
        signIn,
        signUp,
        signOut,
    }
})
