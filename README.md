# 🎉 Hotspot Host Onboarding App

A Flutter application for onboarding hotspot hosts through an interactive questionnaire process.

## 📱 Features Implemented

### ✅ Core Requirements

#### 1. Experience Type Selection Screen

- **API Integration**: Fetches experiences from the staging API using Dio
- **Experience Cards**: 
  - Dynamic grid layout with network images
  - Grayscale filter for unselected states
  - Multi-selection capability
  - Visual selection feedback with animations
- **Text Input**: Multi-line text field with 250 character limit
- **State Management**: BLoC pattern for robust state handling
- **Data Persistence**: Selected experience IDs and description stored in state
- **Navigation**: Smooth page transitions with fade animations

#### 2. Onboarding Question Screen

- **Text Input**: Multi-line text field with 600 character limit

- **Audio Recording**:
  - Real-time waveform visualization during recording
  - Timer display showing recording duration
  - Cancel option while recording
  - Delete recorded audio capability
  - Audio playback with progress indicator
- **Video Recording**:
  - Record from camera or choose from gallery
  - Automatic thumbnail generation
  - Video duration display
  - Delete recorded video capability
  - Full-screen video playback with controls
- **Responsive Layout**: 
  - Dynamic UI adjustments when keyboard opens
  - Smooth scrolling to active input fields
  - Adaptive spacing based on screen size

### ✨ Brownie Points Implemented

#### UI/UX Excellence

- **Pixel-Perfect Design**: 
  - Design system with consistent spacing, fonts, and colors
  - Space Grotesk font family throughout
  - Professional color palette with gradients
- **Responsive Design**:
  - Adaptive layouts for different screen sizes
  - Keyboard-aware UI with automatic scrolling
  - Dynamic text field heights based on available space
  - Character counter with live updates

#### State Management

- **BLoC Pattern**: 
  - `ExperienceBloc` for experience selection flow
  - `QuestionBloc` for question screen state
  - Proper event/state separation
  - Immutable state with copyWith pattern
- **Dio HTTP Client**: 
  - Configured base URL and timeouts
  - Request/response logging
  - Error handling with user feedback

#### Animations & Interactions

- **Experience Selection**: 
  - Reordering animation when card is selected (moves to first position)
  - Smooth color transitions on selection/deselection
  - Shimmer loading states
- **Progress Indicator**: 
  - Custom wave progress painter
  - Animated wave effect
  - Backdrop blur effect on top bar
- **Button Interactions**:
  - Press-down animation feedback
  - Gradient backgrounds with depth effects
  - Disabled state handling

### 🎁 Additional Features (Beyond Requirements)

1. **Audio Playback System**
   - Full audio player with play/pause controls
   - Animated waveform that follows playback progress
   - Current position and total duration display
   - Auto-reset on completion

2. **Video Playback System**
   - Full-screen video player
   - Custom video controls (play/pause, seek)
   - Progress slider with time indicators
   - Auto-hide controls during playback
   - Aspect ratio preservation

3. **Error Handling**
   - Network error states with retry functionality
   - Permission handling for microphone and camera
   - File validation for video processing
   - User-friendly error messages

4. **Loading States**
   - Shimmer effect for loading experiences
   - Processing indicators for video thumbnails
   - Smooth transitions between states

5. **Visual Polish**
   - Background images with overlay effects
   - Glassmorphism effects on UI elements
   - Consistent rounded corners and shadows
   - Professional gradient buttons

## 🏗️ Project Structure

```
lib/
├── bloc/
│   ├── experience/
│   │   └── experience_bloc.dart      # Experience selection logic
│   └── question/
│       └── question_bloc.dart        # Question screen logic
├── constants/
│   ├── app_constants.dart            # Design system constants
│   └── app_spacing.dart              # Spacing guidelines
├── data/
│   ├── api/
│   │   └── api_client.dart           # Dio HTTP client
│   └── repositories/
│       └── experience_repository.dart # Data layer
├── models/
│   └── experience_model.dart         # Experience data model
├── screens/
│   ├── experience_selection_screen.dart
│   └── onboarding_question_screen.dart
├── widgets/
│   ├── audio_recorder_widget.dart    # Audio recording UI
│   ├── video_recorder_widget.dart    # Video recording UI
│   ├── experience_card.dart          # Experience card component
│   └── reusable_widget.dart          # Shared UI components
└── main.dart                         # App entry point
```

## 🛠️ Technologies Used

- **Flutter SDK**: 3.x
- **State Management**: flutter_bloc + equatable
- **HTTP Client**: Dio
- **Audio**: record + audioplayers
- **Video**: image_picker + video_player + video_thumbnail
- **UI Components**: shimmer, flutter_svg
- **Permissions**: permission_handler

## 📦 Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dio: ^5.3.2
  shimmer: ^3.0.0
  image_picker: ^1.0.4
  video_player: ^2.7.2
  video_thumbnail: ^0.5.3
  record: ^5.0.4
  audioplayers: ^5.2.0
  permission_handler: ^11.0.1
  flutter_svg: ^2.0.9
  path_provider: ^2.1.1
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode for running on emulators
- Physical device recommended for audio/video recording

### Installation

1. **Clone the repository**

```bash
git clone <your-repo-url>
cd hotspot_host
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## 🧪 Testing the App

### Experience Selection Screen

1. Wait for experiences to load (shimmer effect)
2. Select multiple experience cards (should turn colorful)
3. Type in the text field (max 250 characters)
4. Click "Next" - check console for logged state
5. Observe smooth transition to next screen

### Question Screen

1. Type in text field (max 600 characters)

2. **Audio Recording**:
   - Tap microphone icon
   - Observe waveform animation
   - Tap stop to save or delete to cancel
   - Play recorded audio
3. **Video Recording**:
   - Tap video icon
   - Choose "Record Video" or "Gallery"
   - Wait for thumbnail generation
   - Tap thumbnail to view in fullscreen

4. Click "Next" - check console for final state



## 👨‍💻 Developer Notes

### Design Decisions
1. **BLoC Pattern**: Chosen for its predictability and testability
2. **Repository Pattern**: Separates business logic from data layer
3. **Reusable Widgets**: Promotes code reuse and consistency
4. **Custom Painters**: Used for complex animations (waveforms, progress)

### Performance Optimizations
- Shimmer placeholders for better perceived performance
- Lazy loading of images
- Efficient state updates with copyWith
- Disposed controllers to prevent memory leaks


## 📝 Assignment Completion Checklist

- [x] Experience list from API
- [x] Selection/deselection on cards
- [x] Grayscale unselected state
- [x] Multi-line text field (250 chars)
- [x] State logging on next
- [x] Multi-line text field (600 chars)
- [x] Audio recording with waveform
- [x] Video recording support
- [x] Cancel while recording
- [x] Delete recorded media
- [x] Dynamic layout handling
- [x] BLoC state management
- [x] Dio for API calls
- [x] Responsive UI design
- [x] Card reorder animation
- [x] Audio playback (bonus)
- [x] Video playback (bonus)

---

📹 **Check out the demo:** [View on Google Drive](https://drive.google.com/drive/folders/1_HDRQZF1ul3qpuhflcEq2QQI3zjGkg6p?usp=sharing)


**Note**: This is an assignment submission for Flutter internship position. All features have been implemented as per requirements with additional enhancements for better user experience.
