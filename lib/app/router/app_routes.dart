abstract final class AppRoutes {
  static const splashName = 'splash';
  static const splashPath = '/';

  static const onboardingName = 'onboarding';
  static const onboardingPath = '/onboarding';

  static const homeName = 'home';
  static const homePath = '/home';

  static const apodName = 'apod';
  static const apodPath = '/apod';
  static const apodDateQueryKey = 'date';

  static const marsRoverName = 'mars-rover';
  static const marsRoverPath = '/mars-rover';

  static const epicEarthName = 'epic-earth';
  static const epicEarthPath = '/epic-earth';

  static const neoName = 'neo';
  static const neoPath = '/neo';

  static const searchName = 'search';
  static const searchPath = '/search';

  static const bookmarksName = 'bookmarks';
  static const bookmarksPath = '/bookmarks';

  static const notificationsName = 'notifications';
  static const notificationsPath = '/notifications';

  static const auroraDemoName = 'aurora-demo';
  static const auroraDemoPath = '/aurora-demo';

  static const settingsName = 'settings';
  static const settingsPath = '/settings';

  static const aboutName = 'about';
  static const aboutPath = '/about';

  static const donationName = 'donation';
  static const donationPath = '/donation';

  static const planets3dName = 'planets-3d';
  static const planets3dPath = '/planets-3d';

  static const planetDetailName = 'planet-detail';
  static const planetDetailPath = '/planets-3d/:id';

  static const wallpapersName = 'wallpapers';
  static const wallpapersPath = '/wallpapers';

  static const wallpaperDetailName = 'wallpaper-detail';
  static const wallpaperDetailPath = '/wallpapers/:id';

  static String wallpaperDetailLocation(String id) => '$wallpapersPath/$id';
}
