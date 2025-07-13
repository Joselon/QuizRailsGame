# QuizGame

**QuizGame** es una aplicación web multijugador inspirada en un trivial clásico, donde varios jugadores pueden unirse a una sala, responder preguntas por turnos y competir para ver quién obtiene la mejor puntuación.
(Es una mejora importante del CRUD de preguntas con ahorcado que tenia en nodeJS en el repo 'quiz' guiado por ChatGPT y desarrollado en un movil andorid usando una terminal Termux+proot-distro debian)

## Características planeadas

- Autenticación de usuarios con [Devise](https://github.com/heartcombo/devise)
- Sistema de salas: los jugadores podrán crear y unirse a salas activas
- Juego por turnos sincronizado en tiempo real con [Action Cable](https://guides.rubyonrails.org/action_cable_overview.html)
- Sistema de preguntas categorizadas con niveles de dificultad
- Gestión de puntuaciones por jugador
- Interfaz sencilla y compatible con dispositivos móviles

## Estado del proyecto

En desarrollo inicial.

Hasta ahora se ha implementado:

- Estructura de modelos: `User`, `Room`, `RoomPlayer`, `Question`, `Turn`
- Autenticación con Devise
- Canal de Action Cable inicial para el sistema de juego
- Controlador y vistas básicas para gestión de salas

## Requisitos

- Ruby 3.2+
- Rails 8.0+
- PostgreSQL
- Node.js y Yarn (para assets JS)

## Instalación y ejecución

```bash
bundle install
rails db:create db:migrate
rails server -b 0.0.0.0 -p 3000
ngrok...

Pending

* System dependencies

* Configuration

* Database creation

Create with user postgres!

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
