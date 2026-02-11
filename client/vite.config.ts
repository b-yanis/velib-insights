import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,      // Nécessaire pour que Docker puisse accéder au port
    port: 3000     // On fixe le port sur 3000
  }
})