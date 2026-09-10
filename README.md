# ProntoTix Backend

Backend service for **ProntoTix**, a field operations management system designed to manage drivers, work shifts, location tracking, delivery reports, and service tickets.

The project originally started as a ticket management system and evolved into a broader platform for managing and tracking field staff operations.

The backend is built with **Swift and Vapor** and provides REST APIs used by the ProntoTix mobile application.

## Tech Stack

* Swift 5.9
* Vapor 4
* Fluent ORM
* PostgreSQL
* JWT Authentication
* Swift Package Manager
* Docker

## Main Features

* User authentication using JWT
* Driver management
* Driver work shift management
* Driver location tracking
* Driver tracking events
* Delivery reports
* Service ticket management
* REST API communication
* PostgreSQL persistence using Fluent ORM

## Architecture

The project separates responsibilities into different layers:

* **Controllers** – Handle HTTP requests and responses
* **Services** – Contain application and business logic
* **Repositories** – Handle data access
* **Models** – Represent database entities
* **DTOs** – Define request and response structures
* **Auth** – Authentication and authorization
* **Configuration** – Application and environment configuration

## Project Structure

```text
Sources/
├── Auth/
├── Configuration/
├── Controllers/
├── DTOs/
├── Models/
├── Repositories/
├── Services/
└── main.swift
```

The API includes controllers for:

* Current user
* Drivers
* Driver shifts
* Driver locations
* Driver tracking events
* Delivery reports
* Tickets

## Android Application

ProntoTix also includes a native Android application developed with **Kotlin and Jetpack Compose**.

The Android application communicates with this backend through REST APIs and provides the mobile interface for field operations.

Repository:

https://github.com/luisvicente2021/ProntoTix-Android

## Running the Project

### Requirements

* Swift 5.9+
* PostgreSQL
* Swift Package Manager

Clone the repository:

```bash
git clone https://github.com/luisvicente2021/ProntoTixBackend.git
cd ProntoTixBackend
```

Resolve dependencies:

```bash
swift package resolve
```

Configure the required environment variables for the database and authentication.

Run the server:

```bash
swift run
```

## About the Project

ProntoTix is a personal software project created to develop a complete solution involving mobile development, backend services, REST APIs, authentication, location tracking, and persistent data.

Building ProntoTix has allowed me to work across different parts of a software product: from backend architecture and API development with Swift and Vapor to integration with a native Android application.

## Author

**Luis Angel Vicente Robles**

Software Engineer | Mobile Developer
Swift • iOS • Kotlin • Android
