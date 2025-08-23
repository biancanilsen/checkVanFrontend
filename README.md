# Check Van: Gestão de Transporte Escolar

O Check Van é o aplicativo completo que conecta pais e motoristas para simplificar e trazer mais segurança à rotina do transporte escolar. Com ele, é possível gerar rotas otimizadas, gerenciar alunos, organizar viagens e muito mais, tudo na palma da sua mão.

<img width="1920" height="1080" alt="capa check van" src="https://github.com/user-attachments/assets/de79a623-8582-4211-a7b4-be5be805f958" />

## Sobre o Projeto

**Check Van** é uma aplicação mobile full-stack para gerenciamento de transporte escolar, desenvolvida com Flutter (frontend) e Node.js (backend). O sistema é projetado para conectar motoristas e responsáveis, centralizando a gestão de alunos, turmas e viagens em uma interface intuitiva.

## Stack Principal

-   **Frontend**: Flutter (Dart)
    -   **Gerenciamento de Estado**: Provider
    -   **Comunicação API**: Pacote `http`
-   **Backend**: Node.js com Express.js
-   **Banco de Dados**: PostgreSQL (ou similar) com Prisma ORM
-   **Autenticação**: Baseada em Token (JWT)

## Funcionalidades Implementadas

#### Autenticação & Autorização
-   Sistema de cadastro e login de usuários.
-   Controle de Acesso Baseado em Função (RBAC) que diferencia a UI e as permissões para perfis `DRIVER` (Motorista) e `GUARDIAN` (Responsável).

#### Módulo de Gestão (Perfil Motorista)
-   **CRUD completo de Alunos**: Criação (com associação a uma escola), leitura, atualização e deleção de estudantes.
-   **CRUD completo de Viagens**: Criação, leitura, atualização e deleção de rotas com pontos de partida e escolas como destino.
-   **CRUD completo de Turmas**: Criação, leitura, atualização e deleção de turmas, associando-as a uma viagem específica.
-   **Associação Aluno-Turma**: Funcionalidade para vincular e desvincular alunos de uma turma específica.

#### Interface de Usuário e UX
-   Interface com Abas (`TabBar`) para organizar os módulos de "Alunos" e "Turmas".
-   Formulários em Bottom Sheets e Modals para uma experiência de usuário moderna na criação e edição de registros.
-   Carregamento de dados sob demanda (*lazy loading*) para informações aninhadas (ex: buscar alunos/turmas apenas ao expandir uma viagem).
-   Busca com `Autocomplete` para adicionar alunos a uma turma de forma eficiente.
-   Listas ordenadas (alfabeticamente ou por horário) diretamente pelo backend.

#### API
-   Endpoints RESTful para todas as operações de CRUD.
-   Rotas protegidas com middleware de autenticação.
-   Respostas formatadas e consistentes em JSON.

### Instruções para uso:
O comando "dart run build_runner build --delete-conflicting-outputs" é necessário sempre que você criar ou modificar classes que usam geração de código automática, como é o caso de modelos com @JsonSerializable().

🔸 10.0.2.2 é o IP especial para acessar o localhost da máquina host a partir do emulador Android.
Se for emulador iOS, use localhost. Se for dispositivo físico, descubra seu IP local com ip a ou ipconfig.


