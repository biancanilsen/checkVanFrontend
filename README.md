# 📘 Manual do Usuário — Check Van

Repositório backend: [**Link aqui**](https://github.com/camily-ghellar/checkVan-backend)

## 1. Primeiros Passos

### 📥 Download

Instale o APK: [**Link aqui**](https://drive.google.com/drive/folders/1G0XgnUrCintn8g7TtMgTMGSGx5UP__Co?usp=sharing) (somente Android)

### 🔐 Cadastro / Login

* Utilize o e-mail e senha fornecidos **ou** crie sua conta.
* **Pais/Responsáveis:** não adicione CNH.

<img width="917" height="515" alt="Captura de Tela 2025-12-10 às 19 51 04" src="https://github.com/user-attachments/assets/5c5a3eb6-9f5e-4847-8209-af182fdc64a7" />

### ⚙️ Configuração Inicial

* **Pai/Responsável:** adicione seu(s) aluno(s) e vincule à escola.
* **Motorista:** crie suas vans, escolas atendidas e turmas.

<img width="922" height="522" alt="Captura de Tela 2025-12-10 às 20 00 25" src="https://github.com/user-attachments/assets/d364c4f5-4689-4e62-a8f3-4af1565cce23" />


## 2. Para o Pai/Responsável

O responsável usa o Check Van para **monitorar, confirmar presença e rastrear** a van escolar.

<img width="920" height="520" alt="Captura de Tela 2025-12-10 às 20 01 39" src="https://github.com/user-attachments/assets/1a9f0ee4-fb34-47d9-8162-b3037627afdc" />


### 2.1 🏠 Tela Inicial (Dashboard)

A tela principal mostra o status da **próxima rota** (Ida ou Volta).

| Status Exibido             | Significado                                        | Ação Sugerida                                  |
| -------------------------- | -------------------------------------------------- | ---------------------------------------------- |
| **EM ROTA**                | Algum filho já embarcou e a van está em movimento. | Clique em **Acompanhar rota**                  |
| **AGUARDANDO CONFIRMAÇÃO** | Presença ainda não informada.                      | Clique no cartão do aluno para confirmar.      |
| **AGUARDANDO OUTROS**      | Presença confirmada, mas a rota não iniciou.       | Aguarde a notificação.                         |
| **NÃO VAI / SEM ALUNO**    | Sem alunos cadastrados ou rota cancelada.          | Verifique se é feriado ou finalize o cadastro. |


### 2.2 ✔️ Confirmação de Presença (Obrigatório)

1. Toque no aluno com status **Pendente** (ou acesse **Alunos**).
2. Navegue pelas semanas usando as setas.
3. Escolha uma opção:

   * **Ida e Volta**
   * **Somente Ida**
   * **Somente Volta**
   * **Não utilizará o transporte**
4. Toque em **Confirmar**.


### 2.3 📍 Acompanhamento em Tempo Real

Disponível **somente quando o motorista está em rota**.

* Toque em **Acompanhar rota** quando o status for **EM ROTA**.
* O mapa abre centralizado no endereço do aluno.

**Ícones do mapa:**

* 🔴 Parada do aluno
* 🔵 Van em tempo real
* ⚠️ “Van não encontrada”: motorista offline ou erro no servidor


### 2.4 👨‍👩‍👧 Gerenciamento de Alunos

* **Adicionar aluno:** botão disponível quando não houver nenhum.
* **Editar aluno:** toque no cartão para alterar endereço, turno etc.


## 3. Para o Motorista

O motorista usa o Check Van para **operar rotas**, **registrar embarques** e **atualizar o rastreamento**.


### 3.1 🛣️ Tela Inicial (Rotas)

* Mostra a **próxima rota** programada.
* Toque em **Iniciar rota** para habilitar a navegação ativa.


### 3.2 🧭 Navegação Ativa

A tela deve permanecer aberta para garantir o envio de localização aos responsáveis.

* GPS envia posição a cada **5 metros de movimento** ou **1 segundo**.
* Instruções por voz (TTS) podem ser silenciadas.

**Marcadores no mapa:**

* 🔵 Localização atual
* 🔴 Paradas dos alunos
* 🔷 Escola (destino final)


### 3.3 🎯 Gerenciamento de Paradas

* Lista inferior mostra alunos em ordem da rota.
* Chegada detectada automaticamente a **100m** da parada.

**No Card de Confirmação:**

* **Embarcar:** confirma entrada do aluno e notifica responsáveis.
* **Ausente:** pula para o próximo endereço.
* **Finalizar Rota:** ao completar o último destino.


### 3.4 🏫 Gestão de Turmas, Escolas e Vans

Menu lateral permite gerenciar:

* Turmas
* Escolas
* Vans
* Horários, alunos e vínculos


# 🏗️ Sobre o Projeto

O **Check Van** é uma aplicação mobile full-stack para gerenciamento de transporte escolar, desenvolvida com **Flutter** (frontend) e **Node.js** (backend).
Ele conecta motoristas e responsáveis, centralizando alunos, turmas e viagens.


## 🚀 Stack Principal

### **Frontend — Flutter (Dart)**

* Gerenciamento de Estado: **Provider**
* Comunicação com API: pacote **http**

### **Backend — Node.js + Express**

### **Banco de Dados**

* **PostgreSQL**
* Prisma ORM

### **Autenticação**

* JWT (Token Based)


## 🧩 Funcionalidades Implementadas


### 🔐 Autenticação & Autorização

* Cadastro e login
  * `DRIVER` (Motorista)
  * `GUARDIAN` (Responsável)


### 🚌 Módulo de Gestão (Motorista)

#### **CRUD de Alunos**

* Criar aluno já vinculado a uma escola
* Editar, visualizar e excluir

#### **CRUD de Viagens**

* Rota com ponto de partida
* Escola como destino

#### **CRUD de Turmas**

* Criação e gerenciamento vinculado à viagem

#### **Associação Aluno–Turma**

* Adicionar e remover alunos de uma turma

### 🚌 Módulo de monitoramento (Responsável)

#### **Moniramento de van em tempo real**

* Disponível para os pais

#### **Notificações**

#### **Recebimento de notificações quando:**
    * O aluno é o próximo a embarcar na van
    * Quando o motorista realiza o embarque do aluno
    * Lembrete de presença todos os dias 20h
    * Quando o motorista finaliza a rota

#### **Confirmação de presença:**
    * Disponível na home do responsável, sendo possível relatar a presença ou ausência do aluno no uso do transporte 
  
### 🎨 UI & UX

* Navegação por **TabBar**
* Formulários em **Bottom Sheets** e **Modals**
* Lazy Loading de dados para melhorar desempenho
* Busca com **Autocomplete** ao adicionar alunos
* Busca de endereço com **Autocomplete**, usando API do Google Maps
* Listas ordenadas automaticamente (alfabética, horários etc.)


### 🌐 API

* Endpoints RESTful completos
* Rotas protegidas por middleware JWT
* Respostas JSON padronizadas


## 🧰 Instruções Técnicas Úteis

### 🔧 Build Runner (Flutter)

Sempre execute ao alterar classes marcadas com `@JsonSerializable()`:

```bash
dart run build_runner build --delete-conflicting-outputs
```


### 🌐 Conexão com API no Emulador

* **Android Emulator:** use `10.0.2.2` para acessar o localhost da máquina hospedeira
* **iOS Simulator:** use `localhost`
* **Dispositivo físico:** descubra o IP com `ip a` ou `ipconfig`

