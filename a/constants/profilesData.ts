import { Dimensions } from 'react-native';

export const { width, height } = Dimensions.get('window');
export const USERS_PER_PAGE = 8; 

export const WORLD_CITIES = ["Budva", "Miami", "London", "Paris", "Tokyo", "Berlin", "Dubai", "New York", "Belgrade", "Rome"];
export const NAMES = ["Sofija", "Emma", "Isabella", "Yuki", "Chloe", "Mila", "Martina", "Valentina", "Luka", "Mateo"];

// 🚀 UPDATED GENDERS AND SEXUALITIES 🚀
export const GENDERS = ["Female", "Male", "Other"];
export const SEXUALITIES = ["Heterosexual", "Gay", "Lesbian", "Bisexual", "Other"];

export const GHOST_STICKERS = ["❤️", "🔥", "🌹", "👋", "✨", "👑", "😍"];

export const ALL_PROFILES = Array.from({ length: 300 }, (_, i) => ({
  id: i.toString(),
  name: NAMES[i % NAMES.length] + " " + (i + 1),
  age: 18 + (i % 25),
  town: WORLD_CITIES[i % WORLD_CITIES.length],
  gender: GENDERS[i % GENDERS.length],
  sexuality: SEXUALITIES[i % SEXUALITIES.length],
  bio: `Greetings from ${WORLD_CITIES[i % WORLD_CITIES.length]}! I am a ${SEXUALITIES[i % SEXUALITIES.length]} ${GENDERS[i % GENDERS.length]} looking for connections. Dateroot is the future of global dating. Stay connected!`,
  image: `https://picsum.photos/id/${(i + 20) % 70}/600/800`,
  isPro: i % 10 === 0,
  isBanned: false,
  isFavorite: false,
  distance: (Math.random() * 50).toFixed(1),
}));