<script setup>
import { ref, onMounted } from 'vue'
import { createConsumer } from '@rails/actioncable' // Importa o Action Cable para comunicação em tempo real

// Variáveis reativas
const comments = ref([])
const newAuthor = ref('')
const newContent = ref('')

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

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
    
    // Limpa o formulário
    newAuthor.value = ''
    newContent.value = ''
  }
}

const deleteComment = async (id) => {
  await fetch(`http://localhost:3000/comments/${id}`, {
    method: 'DELETE'
  })
}

// Executa a busca assim que a tela carrega
onMounted(() => {
  fetchComments()
  const cable = createConsumer('ws://localhost:3000/cable')

  cable.subscriptions.create("CommentsChannel", {
    received(data) {
      if (data.deleted) {
        // Remove o comentário da lista se for uma notificação de exclusão
        comments.value = comments.value.filter(c => c.id !== data.id)
      } else {
        // Adiciona ou atualiza o comentário na lista
        if (!comments.value.find(c => c.id === data.id)) {
          comments.value.unshift(data)
        }
      }
    }
  })
})

</script>

<style scoped>
/* Container principal para centralizar e dar respiro */
.main-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 20px;
}

/* O Wrapper mágico: coloca publicação e form lado a lado */
.post-wrapper {
  display: flex; /* Ativa o Flexbox */
  flex-direction: row; /* Coloca os itens na mesma linha (padrão) */
  gap: 20px; /* Dá um espaço entre a publicação e o formulário */
  margin-bottom: 30px; /* Separa da lista de comentários */
}

/* Estilo para a caixa da publicação */
.publication-box {
  flex: 2; /* Faz esta caixa ocupar 2/3 do espaço disponível */
  border: 1px solid; /* Cria o efeito de caixa */
  padding: 20px;
  border-radius: 8px; /* Cantos arredondados conceitual */
}

/* Estilo para a caixa do formulário */
.form-box {
  flex: 1; /* Faz esta caixa ocupar 1/3 do espaço disponível */
  border: 1px solid; /* Cria o efeito de caixa */
  padding: 20px;
  border-radius: 8px; /* Cantos arredondados conceitual */
  display: flex; /* Opcional: Flexbox interno para alinhar os inputs */
  flex-direction: column;
  gap: 10px;
}

/* Estilo para a lista de comentários embaixo */
.comments-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

/* Estilo para cada item de comentário individual */
.comment-item {
  border: 1px solid;
  padding: 15px;
  border-radius: 5px;
}
</style>

<template>
  <div class="main-container">
    <h2>Sistema de Comentários</h2>

    <div class="post-wrapper">
      
      <div class="publication-box">
        <h3>Artemis II</h3>
        <img src="/img.jpg" alt="Imagem da publicação" style="max-width: 100%; border-radius: 4px;">
      </div>

      <div class="form-box">
        <h4>Deixe seu comentário</h4>
        <form @submit.prevent="createComment" style="display: flex; flex-direction: column; gap: 10px;">
          
          <input v-model="newAuthor" placeholder="Seu nome" required style="padding: 8px; border-radius: 4px; border: 1px solid #ccc;"/>
          
          <textarea v-model="newContent" placeholder="Escreva seu comentário..." required style="padding: 8px; border-radius: 4px; border: 1px solid #ccc; height: 100px; resize: vertical;"></textarea>
          
          <button type="submit" style="padding: 10px; border-radius: 4px; border: none; background-color: #42b883; color: white; font-weight: bold; cursor: pointer;">
            Enviar Comentário
          </button>
        </form>
      </div>

    </div> 

    <div class="comments-list">
      <h4>Comentários ({{ comments.length }})</h4>
      
      <div v-for="comment in comments" :key="comment.id" class="comment-item" style="position: relative;">
        <div style="display: flex; flex-direction: column;">
          <strong>{{ comment.author }}</strong>
          <span style="font-size: 0.75rem; color: #888;">{{ formatDate(comment.created_at) }}</span>
        </div>
        <p style="margin-top: 5px; color: #333;">{{ comment.content }}</p>
        
        <button
          @click="deleteComment(comment.id)"
          style="position: absolute; top: 10px; right: 10px; background: none; border: none; color: #ff4c4c; font-weight: bold; cursor: pointer;"
          title="Excluir Comentário">
          X
        </button>
      </div>
      
      <p v-if="comments.length === 0" style="color: #DDD; font-style: italic;">
        Seja o primeiro a comentar!
      </p>

    </div>
  </div>
</template>