<script setup>
import { ref, onMounted } from 'vue'
import { createConsumer } from '@rails/actioncable' // Importa o Action Cable para comunicação em tempo real

// Variáveis reativas
const comments = ref([])
const newAuthor = ref('')
const newContent = ref('')

// Busca os comentários na API do Rails
const fetchComments = async () => {
  try {
    const response = await fetch('http://localhost:3000/comments')
    comments.value = await response.json()
  } catch (error) {
    console.error("Erro ao buscar comentários:", error)
  }
}

// Envia um novo comentário para a API
const createComment = async () => {
  if (!newAuthor.value || !newContent.value) return

  const response = await fetch('http://localhost:3000/comments', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ 
      comment: { author: newAuthor.value, content: newContent.value } 
    })
  })

  if (response.ok) {
    const comment = await response.json()
    // Adiciona o novo comentário no topo da lista localmente
    comments.value.unshift(comment) 
    
    // Limpa o formulário
    newAuthor.value = ''
    newContent.value = ''
  }
}

// Executa a busca assim que a tela carrega
onMounted(() => {
  fetchComments()

  // Conecta ao WebSocket do Rails
  const cable = createConsumer('ws://localhost:3000/cable')

  cable.subscriptions.create("CommentsChannel", {
    received(data) {
      // Quando receber um dado novo pelo socket, coloca na lista
      // Verificamos se já não está na lista para evitar duplicados
      if (!comments.value.find(c => c.id === data.id)) {
        comments.value.unshift(data)
      }
    }
  })
})
</script>

<template>
  <div style="max-width: 600px; margin: 0 auto; padding: 20px; font-family: sans-serif;">
    <h2>Sistema de Comentários</h2>

    <form @submit.prevent="createComment" style="display: flex; flex-direction: column; gap: 10px; margin-bottom: 30px;">
      <input v-model="newAuthor" placeholder="Seu nome" required style="padding: 8px;" />
      <textarea v-model="newContent" placeholder="Escreva seu comentário..." required style="padding: 8px; height: 80px;"></textarea>
      <button type="submit" style="padding: 10px; background-color: #42b883; color: white; border: none; cursor: pointer;">
        Enviar Comentário
      </button>
    </form>

    <div style="display: flex; flex-direction: column; gap: 15px;">
      <div v-for="comment in comments" :key="comment.id" style="border: 1px solid #ddd; padding: 15px; border-radius: 5px;">
        <strong>{{ comment.author }}</strong>
        <p style="margin: 5px 0 0 0;">{{ comment.content }}</p>
      </div>
    </div>
  </div>
</template>