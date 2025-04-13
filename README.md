# LocalMeat - Farm to Consumer App

## Overview
LocalMeat connects consumers with local farmers to buy quality meat in bulk directly from the source. The app facilitates request posting, farm discovery, and direct communication between farmers and consumers.

## Features Implemented

### Map Integration
- MapKit-based map view showing farm locations
- Interactive pins with farm information
- Toggle between map and list view

### Data Management
- JSON-based mock data for farms, requests, and user profiles
- State management using @State, @EnvironmentObject, and ObservableObject
- Dynamic data filtering and searching

### User Experience
- Dynamic navigation based on user type (Consumer vs Farmer)
- Search & filter functionality for farm listings  
- Star-rating system for farms
- Local push notifications for requests and messages

### User Interfaces
- Farm listings with detailed information
- Request creation and management
- Messaging system between farmers and consumers
- User profiles and account management

## Future Additions
- Stripe SDK integration for in-app payments
- Enhanced analytics for farmers
- Reviews and ratings system
- Order tracking
- Delivery coordination

## Technical Details
- Built with SwiftUI
- Uses MapKit for location features
- Local notifications through UNUserNotificationCenter
- JSON data management
- Environmental state management

## Getting Started
1. Clone the repository
2. Open the project in Xcode
3. Build and run the app
4. Log in as either a farmer or consumer to explore the different features

## Requirements
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+ 