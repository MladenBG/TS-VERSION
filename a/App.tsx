import React, { useState, useEffect, useMemo, useRef } from 'react';
import { 
  View, 
  TextInput, 
  TouchableOpacity, 
  Text,
  FlatList, 
  Image, 
  Alert, 
  ScrollView, 
  StatusBar, 
  Animated, 
  PanResponder,
  Vibration,
  Platform
} from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createNavigationContainerRef } from '@react-navigation/native';
import io from 'socket.io-client';
// 🚀 FIXED: CHANGED LogLevel TO LOG_LEVEL FOR NEWER VERSIONS
import Purchases, { LOG_LEVEL } from 'react-native-purchases'; 
// 🚀 NEW: IMPORT ASYNC STORAGE FOR PERSISTENCE 🚀
import AsyncStorage from '@react-native-async-storage/async-storage';

import { 
  ALL_PROFILES, 
  width, 
  USERS_PER_PAGE, 
  NAMES, 
  GHOST_STICKERS, 
  SEXUALITIES 
} from './constants/profilesData';
import { UserCard } from './components/UserCard';
import { AllModals } from './components/Modals';

import { Lobby } from './components/Lobby';
import { HeaderSwipe } from './components/HeaderSwipe';
import { SwipeButton } from './components/SwipeButton';
import { Subscription } from './components/Subscription';
import { EditProfile } from './components/EditProfile';
import { UserDashboard } from './components/UserDashboard';
import { AdminDashboard } from './components/AdminDashboard';
import { CloudflareVideoCall } from './components/CloudflareVideoCall'; 
import { Inbox } from './components/Inbox';
import { InvisibleModeToggle } from './components/InvisibleModeToggle';

import { HomeScreen } from './screens/HomeScreen';
import { LoginScreen } from './screens/LoginScreen';
import { SignUpScreen } from './screens/SignUpScreen';

import { SafeAreaView, SafeAreaProvider } from 'react-native-safe-area-context';

const logoImg = require('./assets/logo.png');

// =========================================================================
// 🚨 THE MASTER URL SWITCH 🚨
// =========================================================================
const API_URL = "http://10.0.2.2:3000"; 
const SOCKET_URL = "http://10.0.2.2:3001"; 
// =========================================================================

export const socket = io(SOCKET_URL);
const Stack = createStackNavigator();

export const navigationRef = createNavigationContainerRef();

export default function App() {
  const [tab, setTab] = useState<'discover' | 'lobby' | 'favorites' | 'admin' | 'settings' | 'inbox'>('discover');
  const [favTab, setFavTab] = useState<'my_likes' | 'liked_me' | 'viewed_me'>('my_likes');

  const [discoveryMode, setDiscoveryMode] = useState<'list' | 'swipe' | 'radar'>('list');
  const [showPaywall, setShowPaywall] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [showEditProfile, setShowEditProfile] = useState(false);
  
  const [isAdmin, setIsAdmin] = useState(false); 
  const [isVip, setIsVip] = useState(false);

  // 🚀 SHARED MESSAGE LIMIT STATE 🚀
  const [totalFreeMessages, setTotalFreeMessages] = useState(0);
  const [lastResetDate, setLastResetDate] = useState(Date.now());
  const [myImage, setMyImage] = useState("");  
  const [profiles, setProfiles] = useState<any[]>([]);
  const [likedMeProfiles, setLikedMeProfiles] = useState<any[]>([]);
  const [viewedMeProfiles, setViewedMeProfiles] = useState<any[]>([]);
  
  const [receivedGifts, setReceivedGifts] = useState<any[]>([]);
  
  const [searchQuery, setSearchQuery] = useState('');
  const [filterGender, setFilterGender] = useState('All');
  const [filterSexuality, setFilterSexuality] = useState('All');
  
  const [adminSearch, setAdminSearch] = useState('');
  const [currentPage, setCurrentPage] = useState(1);

  const [selectedUser, setSelectedUser] = useState<any>(null);
  const [chatUser, setChatUser] = useState<any>(null);
  const [messages, setMessages] = useState<Record<string, any[]>>({});
  const [chatInput, setChatInput] = useState('');

  const [unreadCount, setUnreadCount] = useState(0);
  const currentTab = useRef(tab);

  const [lobbyMessages, setLobbyMessages] = useState<any[]>([]);
  const [lobbyInput, setLobbyInput] = useState('');
  const [myId, setMyId] = useState("test_user_id");
  const [myName, setMyName] = useState('');
  const [myCity, setMyCity] = useState('');
  
  const [isPrivate, setIsPrivate] = useState(false); 
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);

  // 🚀 CORRECTED: PROFILE LIST SYNC ENGINE 🚀
  // This watcher forces the search list to update your card when you change your picture
  useEffect(() => {
    if (myId && myImage) {
      setProfiles(prevProfiles => 
        prevProfiles.map(p => p.id === myId ? { ...p, image: myImage } : p)
      );
    }
  }, [myImage, myId]);

  // =========================================================================
  // 🚀 LOAD MESSAGE LIMITS FROM PHONE STORAGE ON APP START 🚀
  // =========================================================================
  useEffect(() => {
    const loadMessageLimits = async () => {
      try {
        const storedCount = await AsyncStorage.getItem('totalFreeMessages');
        const storedDate = await AsyncStorage.getItem('lastResetDate');

        if (storedDate) {
          const parsedDate = parseInt(storedDate, 10);
          const fiveDaysInMs = 5 * 24 * 60 * 60 * 1000;
          
          if (Date.now() - parsedDate > fiveDaysInMs) {
            setTotalFreeMessages(0);
            setLastResetDate(Date.now());
            await AsyncStorage.setItem('totalFreeMessages', '0');
            await AsyncStorage.setItem('lastResetDate', Date.now().toString());
          } else {
            setTotalFreeMessages(storedCount ? parseInt(storedCount, 10) : 0);
            setLastResetDate(parsedDate);
          }
        } else {
          await AsyncStorage.setItem('lastResetDate', Date.now().toString());
        }
      } catch (e) {
        console.error("Failed to load storage", e);
      }
    };
    loadMessageLimits();
  }, []);

  // 🚀 HELPER TO SAVE NEW COUNT TO HARD DRIVE
  const incrementMessageCount = async () => {
    if (isAdmin || isVip) return; 
    const newCount = totalFreeMessages + 1;
    setTotalFreeMessages(newCount);
    await AsyncStorage.setItem('totalFreeMessages', newCount.toString());
  };

  // =========================================================================
  // 🚀 REVENUECAT INITIALIZATION FOR GOOGLE PLAY 🚀
  // =========================================================================
  useEffect(() => {
    const setupRevenueCat = async () => {
      try {
        Purchases.setLogLevel(LOG_LEVEL.DEBUG);
        if (Platform.OS === 'android') {
          // Purchases.configure({ apiKey: "YOUR_REVENUECAT_GOOGLE_API_KEY" });
        } else if (Platform.OS === 'ios') {
          // Purchases.configure({ apiKey: "YOUR_REVENUECAT_APPLE_API_KEY" });
        }
      } catch (e) {
        console.error("Error initializing RevenueCat", e);
      }
    };
    setupRevenueCat();
  }, []);

  // 🚀 LOAD USERS, LOBBY HISTORY, AND INBOX HISTORY ON START/REFRESH
  useEffect(() => {
    const fetchInitialData = async () => {
      try {
        const res = await fetch(`${API_URL}/api/users`);
        const data = await res.json();
        
        if (data && !data.error) {
          const formattedProfiles = data.map((u: any) => ({
            id: u.id,
            name: u.name,
            age: u.age || 25,
            town: u.city || 'Unknown',
            image: u.image || 'https://via.placeholder.com/150',
            gender: u.gender || 'Unknown',
            sexuality: u.sexuality || 'Straight',
            bio: u.bio || '',
            is_vip: u.is_vip,
            isFavorite: u.isFavorite, 
            distance: Math.floor(Math.random() * 10) + 1,
            isBanned: false,
            friends: u.friends || [],
            gifts: u.gifts || [],
            gallery: u.gallery || []
          }));
          setProfiles(formattedProfiles);
        }

        const likedRes = await fetch(`${API_URL}/api/likes/who-liked-me`);
        const likedData = await likedRes.json();
        if (!likedData.error) setLikedMeProfiles(likedData);

        const viewsRes = await fetch(`${API_URL}/api/views`);
        const viewsData = await viewsRes.json();
        if (!viewsData.error) setViewedMeProfiles(viewsData);

        const giftsRes = await fetch(`${API_URL}/api/gifts`);
        const giftsData = await giftsRes.json();
        if (!giftsData.error) setReceivedGifts(giftsData);

        const lobbyRes = await fetch(`${API_URL}/api/lobby`);
        const lobbyData = await lobbyRes.json();
        if (!lobbyData.error && Array.isArray(lobbyData)) {
           setLobbyMessages(lobbyData);
        }

        if (myId) {
          const msgRes = await fetch(`${API_URL}/api/messages?my_id=${myId}`);
          const msgData = await msgRes.json();
          if (!msgData.error) {
            setMessages(msgData);
          }
        }

      } catch (error) {
        console.error("Failed to load initial data:", error);
      }
    };

    fetchInitialData();
  }, [myId]);

  // 🚀 LOAD SPECIFIC CHAT HISTORY WHEN A USER IS CLICKED
  useEffect(() => {
    if (chatUser && myId) {
      const fetchChatHistory = async () => {
        try {
          const res = await fetch(`${API_URL}/api/messages?my_id=${myId}&other_id=${chatUser.id}`);
          const history = await res.json();
          if (!history.error) {
            setMessages(prev => ({ ...prev, [chatUser.id]: history }));
          }
        } catch (error) {
          console.error("Failed to fetch messages:", error);
        }
      };
      fetchChatHistory();
    }
  }, [chatUser, myId]);

  useEffect(() => {
    currentTab.current = tab;
    if (tab === 'inbox') {
      setUnreadCount(0);
    }
  }, [tab]);

  const playNotificationSound = async () => { Vibration.vibrate(); };

  const [swipeIndex, setSwipeIndex] = useState(0);
  const position = useRef(new Animated.ValueXY()).current;

  const toggleInvisibleMode = async (newValue: boolean) => {
    setIsPrivate(newValue); 
    try {
      await fetch(`${API_URL}/api/settings/invisible`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_invisible: newValue })
      });
    } catch (error) {
      console.error("Failed to update invisible mode:", error);
      setIsPrivate(!newValue); 
    }
  };

  const radarAnim = useRef(new Animated.Value(0)).current;
  
  useEffect(() => {
    if (discoveryMode === 'radar') {
      Animated.loop(
        Animated.timing(radarAnim, {
          toValue: 1,
          duration: 3000,
          useNativeDriver: true,
        })
      ).start();
    }
  }, [discoveryMode, radarAnim]);

  // 🚀 SOCKET INITIALIZATION & LISTENERS
  useEffect(() => {
    if (myName) {
      socket.emit("register_user", myName); 
    }

    const handleReceiveLobby = (msg: any) => {
      setLobbyMessages(prev => [msg, ...prev]);
    };
    
    socket.on("receive_lobby_msg", handleReceiveLobby);

    const handleIncomingCall = (data: any) => {
      Vibration.vibrate([1000, 2000, 1000, 2000]); 
      
      Alert.alert(
        "📹 Incoming Video Date!",
        `${data.callerName} is calling you via Secure Video.`,
        [
          { 
            text: "Decline", 
            style: "destructive",
            onPress: () => {
              Vibration.cancel();
              socket.emit("decline_call", { callerId: data.callerId });
            }
          },
          { 
            text: "Accept", 
            style: "default",
            onPress: () => {
              Vibration.cancel();
              if (navigationRef.isReady()) {
                (navigationRef as any).navigate('CloudflareVideoCall', { 
                  chatUserName: data.callerName,
                  remoteSessionId: data.cloudflareSessionId
                });
              }
            }
          }
        ]
      );
    };

    socket.on("incoming_call", handleIncomingCall);
    
    return () => { 
      socket.off("receive_lobby_msg", handleReceiveLobby); 
      socket.off("incoming_call", handleIncomingCall); 
      Vibration.cancel();
    };
  }, [myName]);

  const filteredProfiles = useMemo(() => {
    return profiles.filter(p => {
      const s = searchQuery.toLowerCase();
      
      const matchesSearch = !p.isBanned && (
        p.town.toLowerCase().includes(s) || 
        p.name.toLowerCase().includes(s) ||
        p.sexuality.toLowerCase().includes(s)
      );
      
      const matchesGender = filterGender === 'All' || p.gender === filterGender;
      const matchesSexuality = filterSexuality === 'All' || p.sexuality === filterSexuality;
      
      return matchesSearch && matchesGender && matchesSexuality;
    });
  }, [profiles, searchQuery, filterGender, filterSexuality]);

  const favoriteProfiles = profiles.filter(p => p.isFavorite && !p.isBanned);
  
  const adminFiltered = profiles.filter(p => 
    p.name.toLowerCase().includes(adminSearch.toLowerCase())
  );

  const totalPages = Math.ceil(filteredProfiles.length / USERS_PER_PAGE);
  const currentUsers = filteredProfiles.slice(
    (currentPage - 1) * USERS_PER_PAGE, 
    currentPage * USERS_PER_PAGE
  );

  const panResponder = PanResponder.create({
    onStartShouldSetPanResponder: () => true,
    onPanResponderMove: (event, gesture) => {
      position.setValue({ x: gesture.dx, y: gesture.dy });
    },
    onPanResponderRelease: (event, gesture) => {
      if (gesture.dx > 120) {
        completeSwipe('right');
      } else if (gesture.dx < -120) {
        completeSwipe('left');
      } else {
        Animated.spring(position, { toValue: { x: 0, y: 0 }, friction: 4, useNativeDriver: true }).start();
      }
    }
  });

  const completeSwipe = (direction: 'left' | 'right') => {
    Animated.timing(position, {
      toValue: { x: direction === 'right' ? width * 1.5 : -width * 1.5, y: 0 },
      duration: 300,
      useNativeDriver: true
    }).start(() => {
      if (direction === 'right') {
        toggleLike(filteredProfiles[swipeIndex].id);
      }
      position.setValue({ x: 0, y: 0 });
      setSwipeIndex(prev => prev + 1);
    });
  };

  const handleProfileView = async (user: any) => {
    setSelectedUser(user);
    try {
      await fetch(`${API_URL}/api/views`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ viewed_id: user.id })
      });
    } catch (error) {
      console.error("View not recorded:", error);
    }
  };

  const toggleLike = async (liked_user_id: string) => {
    setProfiles(prev => prev.map(p => 
      p.id === liked_user_id ? { ...p, isFavorite: !p.isFavorite } : p
    ));

    try {
      await fetch(`${API_URL}/api/likes`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ liked_user_id: liked_user_id })
      });
    } catch (error) {
      console.error("Database connection failed for like:", error);
    }
  };

  const checkMessageLimits = () => {
    if (isAdmin || isVip) return true;

    const fiveDaysInMs = 5 * 24 * 60 * 60 * 1000;
    if (Date.now() - lastResetDate > fiveDaysInMs) {
      setTotalFreeMessages(0); 
      setLastResetDate(Date.now());
    }

    if (totalFreeMessages >= 2) {
      Alert.alert(
        "Out of Free Messages! 🛑", 
        "You have used your 2 free messages across the app. Subscribe to VIP to chat unlimited!",
        [
          { text: "Cancel", style: "cancel" },
          { text: "Unlock VIP", onPress: () => setShowPaywall(true) } 
        ]
      );
      return false; 
    }

    return true;
  };

  const handleSendMessage = async () => {
    if (!chatInput.trim() || !chatUser || !myId) return;
    
    if (!checkMessageLimits()) return;
    
    const textToSend = chatInput;
    setChatInput('');

    const tempId = 'temp_' + Date.now().toString();
    const tempMsg = { 
      id: tempId, 
      text: textToSend, 
      sender: 'me',
      name: myName
    };
    
    setMessages(prev => ({ 
      ...prev, 
      [chatUser.id]: [...(prev[chatUser.id] || []), tempMsg] 
    }));
    
    try {
      const res = await fetch(`${API_URL}/api/messages`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sender_id: myId, receiver_id: chatUser.id, content: textToSend })
      });

      const realDbMessage = await res.json();

      if (realDbMessage && realDbMessage.id) {
        setMessages(prev => {
          const updatedChat = (prev[chatUser.id] || []).map(m => 
            m.id === tempId ? { ...m, id: realDbMessage.id } : m
          );
          return { ...prev, [chatUser.id]: updatedChat };
        });
      }
      incrementMessageCount(); 

    } catch (error) {
      console.error("Database connection failed for message:", error);
    }
  };

  const sendLobbyMessage = async () => {
    if (!lobbyInput.trim() || !myName || !myId) return; 
    
    if (!checkMessageLimits()) return;
    
    const msgText = lobbyInput;
    setLobbyInput('');
    
    try {
      const res = await fetch(`${API_URL}/api/lobby`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sender_id: myId, content: msgText })
      });
      
      const dbData = await res.json();
      
      const finalMsg = { 
        id: dbData.id ? dbData.id.toString() : Date.now().toString(), 
        user: myName, 
        text: msgText, 
        time: dbData.time || new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) 
      };
      
      socket.emit("send_lobby_msg", finalMsg);
      setLobbyMessages(prev => [finalMsg, ...prev]);

      incrementMessageCount(); 

    } catch (error) {
      console.error("Failed to save lobby message:", error);
    }
  };
  
  const handleStartVideoCall = (user: any) => {
    if (!isAdmin && !isVip) {
      Alert.alert("Premium Feature", "Video Calling is locked. You must subscribe to use the camera!");
      setShowPaywall(true);
      return;
    }
    
    socket.emit("start_call", { 
      callerId: myName, 
      callerName: myName, 
      receiverId: user.name, 
      cloudflareSessionId: "generating..." 
    });

    if (navigationRef.isReady()) {
      (navigationRef as any).navigate('CloudflareVideoCall', { chatUserName: user.name });
    }
  };

  const handleAddFriend = async (user: any) => {
    if (!isAdmin && !isVip) {
      Alert.alert(
        "Premium Feature", 
        "Building a friend list is a VIP exclusive feature! Subscribe to unlock."
      );
      setShowPaywall(true);
      return;
    }

    Alert.alert("Friend Request Sent", `You sent a friend request to ${user.name}!`);

    try {
      await fetch(`${API_URL}/api/friends`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ friend_id: user.id })
      });
    } catch (error) {
      console.error("Failed to add friend:", error);
    }
  };

  const handleSendGift = async (user: any, giftName: string) => {
    if (!isAdmin && !isVip) {
      Alert.alert("Premium Feature", "Sending gifts is a VIP exclusive feature. Subscribe to stand out!");
      setShowPaywall(true);
      return;
    }

    Alert.alert("Gift Sent!", `You sent a ${giftName} to ${user.name}!`);
    
    try {
      await fetch(`${API_URL}/api/gifts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ receiver_id: user.id, gift_name: giftName })
      });
    } catch (error) {
      console.error("Failed to send gift:", error);
    }
  };

  const handlePayment = (plan: string) => {
    Alert.alert("Dateroot Secure", `Purchase ${plan} plan for full access?`, [
      { text: "Cancel", style: "cancel" },
      { 
        text: "Pay Now", 
        onPress: () => { 
          setIsVip(true); 
          setShowPaywall(false); 
          Alert.alert("Success", "VIP UNLOCKED"); 
        }
      }
    ]);
  };

  return (
    <SafeAreaProvider> 
    <NavigationContainer ref={navigationRef}>
      <Stack.Navigator screenOptions={{ headerShown: false }} initialRouteName="Home">
        
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="SignUp" component={SignUpScreen} />

        <Stack.Screen name="Main">
          {({ navigation, route }: any) => {

            useEffect(() => {
              if (route.params?.user) {
                setMyId(route.params.user.id);
                setMyName(route.params.user.name || 'User');
                setIsAdmin(route.params.user.role === 'admin'); 
                setIsVip(route.params.user.is_vip || false);
                if (route.params.user.city) setMyCity(route.params.user.city);
                // 🚀 FIXED: LOGIN DATA CATCHER (Line 840)
                if (route.params.user.image) setMyImage(route.params.user.image);
              }
            }, [route.params]);

            const handleLogout = () => {
              Alert.alert("Sign Out", "Are you sure you want to log out?", [
                { text: "Cancel", style: "cancel" },
                { 
                  text: "Logout", 
                  style: "destructive",
                  onPress: () => {
                    navigation.replace('Home');
                  }
                }
              ]);
            };

            return (
              <SafeAreaView className="flex-1 bg-white">
                <StatusBar barStyle="dark-content" />
                
                {tab !== 'admin' && tab !== 'settings' && tab !== 'inbox' && (
                  <HeaderSwipe 
                    logoImg={logoImg} 
                    myImage={myImage}       // 🚀 PICTURE ADDED TO SEARCH HEADER (Line 865)
                    isVip={isVip} 
                    setShowPaywall={setShowPaywall} 
                    tab={tab} 
                    searchQuery={searchQuery} 
                    setSearchQuery={setSearchQuery} 
                    setCurrentPage={setCurrentPage}
                    setShowFilters={setShowFilters} 
                    setTab={setTab} 
                    setDiscoveryMode={setDiscoveryMode} 
                    discoveryMode={discoveryMode} 
                    unreadCount={unreadCount}
                    handleLogout={handleLogout} 
                  />
                )}

                <View className="flex-1">
                  {tab === 'discover' && (
                    <View className="flex-1 relative">
                      {discoveryMode === 'list' && (
                        <>
                          <FlatList 
                            data={currentUsers} 
                            renderItem={({item}) => (
                              <UserCard 
                                item={item} 
                                onSelect={handleProfileView} 
                                onToggleLike={toggleLike} 
                              />
                            )} 
                            numColumns={2} 
                            keyExtractor={item => item.id}
                            contentContainerStyle={{ padding: 4, paddingBottom: 80 }}
                            ListEmptyComponent={
                              <Text className="text-center mt-12 text-gray-400">
                                No results found in your area.
                              </Text>
                            }
                          />
                          <View className="h-[70px] flex-row justify-between items-center px-5 border-t border-gray-200">
                            <TouchableOpacity 
                              onPress={() => setCurrentPage(prev => Math.max(prev - 1, 1))} 
                              className="bg-green-500 p-2.5 rounded-lg min-w-[80px] items-center"
                            >
                              <Text className="text-white font-bold">Prev</Text>
                            </TouchableOpacity>
                            
                            <Text className="text-gray-800 font-bold text-base">
                              {currentPage} / {totalPages || 1}
                            </Text>
                            
                            <TouchableOpacity 
                              onPress={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))} 
                              className="bg-green-500 p-2.5 rounded-lg min-w-[80px] items-center"
                            >
                              <Text className="text-white font-bold">Next</Text>
                            </TouchableOpacity>
                          </View>

                          <TouchableOpacity 
                            onPress={() => { setTab('favorites'); setFavTab('viewed_me'); }}
                            className="absolute bottom-24 right-6 bg-white/70 border border-white/60 rounded-full px-5 py-3 flex-row items-center shadow-lg backdrop-blur-md"
                            style={{ elevation: 5, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.15, shadowRadius: 8 }}
                          >
                            <Text className="text-[20px] mr-2">👁️</Text>
                            <Text className="font-black text-gray-800 tracking-tight">
                              {viewedMeProfiles.length} Views
                            </Text>
                            {viewedMeProfiles.length > 0 && (
                              <View className="absolute top-0 right-0 bg-red-500 w-3 h-3 rounded-full border border-white" />
                            )}
                          </TouchableOpacity>
                        </>
                      )}

                      {discoveryMode === 'swipe' && isVip && (
                        <View className="flex-1 items-center justify-center">
                          {filteredProfiles.slice(swipeIndex, swipeIndex + 3).reverse().map((p, i) => {
                            const isTop = i === 2 || (filteredProfiles.length - swipeIndex < 3 && i === filteredProfiles.length - swipeIndex - 1);
                            return (
                              <Animated.View 
                                key={p.id} 
                                className="absolute w-[90%] h-[60%] rounded-[20px] overflow-hidden bg-white shadow-lg elevation-5"
                                style={isTop ? { transform: position.getTranslateTransform() } : {}}
                                {...(isTop ? panResponder.panHandlers : {})}
                              >
                                <Image source={{uri: p.image}} className="w-full h-[80%]" />
                                <View className="p-4">
                                  <Text className="text-[22px] font-bold">{p.name}, {p.age}</Text>
                                  <Text className="text-[14px] text-gray-500">{p.town} • {p.sexuality}</Text>
                                </View>
                              </Animated.View>
                            );
                          })}
                          <SwipeButton completeSwipe={completeSwipe} />
                        </View>
                      )}

                      {discoveryMode === 'radar' && isVip && (
                        <View className="flex-1 justify-center items-center bg-gray-50">
                          <Animated.View 
                            className="absolute w-[100px] h-[100px] rounded-full border-2 border-green-500"
                            style={{
                              transform: [{ scale: radarAnim.interpolate({ inputRange: [0, 1], outputRange: [0, 4] }) }],
                              opacity: radarAnim.interpolate({ inputRange: [0, 1], outputRange: [1, 0] })
                            }} 
                          />
                          <View className="w-[15px] h-[15px] rounded-full bg-green-500 elevation-5" />
                          {filteredProfiles.slice(0, 6).map((p, i) => (
                            <TouchableOpacity 
                              key={p.id} 
                              onPress={() => setSelectedUser(p)}
                              className="absolute items-center"
                              style={{ top: 150 + Math.sin(i) * 100, left: (width/2 - 25) + Math.cos(i) * 100 }}
                            >
                              <Image source={{uri: p.image}} className="w-[50px] h-[50px] rounded-full border-2 border-white" />
                              <Text className="text-[10px] text-gray-500 font-bold">{p.distance}km</Text>
                            </TouchableOpacity>
                          ))}
                          <Text className="absolute bottom-12 text-gray-400 font-bold">
                            Scanning for connections in {myCity}...
                          </Text>
                        </View>
                      )}
                    </View>
                  )}

                  {tab === 'inbox' && (
                    <Inbox 
                      messages={messages}
                      setMessages={setMessages}
                      profiles={profiles}
                      setChatUser={setChatUser}
                      setTab={setTab}
                    />
                  )}

                  {tab === 'lobby' && (
                    <Lobby 
                      lobbyMessages={lobbyMessages} 
                      lobbyInput={lobbyInput} 
                      setLobbyInput={setLobbyInput} 
                      sendLobbyMessage={sendLobbyMessage}
                      isAdmin={isAdmin}          
                      isVip={isVip}            
                      setShowPaywall={setShowPaywall}
                      totalFreeMessages={totalFreeMessages} 
                      setTotalFreeMessages={setTotalFreeMessages}
                    />
                  )}

                  {tab === 'favorites' && (
                    <View className="flex-1 bg-gray-50">
                      <View className="flex-row border-b border-gray-200 bg-white">
                        <TouchableOpacity 
                          onPress={() => setFavTab('my_likes')} 
                          className={`flex-1 p-4 items-center ${favTab === 'my_likes' ? 'border-b-2 border-green-500' : ''}`}
                        >
                          <Text className={`font-bold ${favTab === 'my_likes' ? 'text-green-500' : 'text-gray-400'}`}>❤️ I Liked</Text>
                        </TouchableOpacity>
                        
                        <TouchableOpacity 
                          onPress={() => setFavTab('liked_me')} 
                          className={`flex-1 p-4 items-center ${favTab === 'liked_me' ? 'border-b-2 border-green-500' : ''}`}
                        >
                          <Text className={`font-bold ${favTab === 'liked_me' ? 'text-green-500' : 'text-gray-400'}`}>✨ Liked Me</Text>
                        </TouchableOpacity>
                        
                        <TouchableOpacity 
                          onPress={() => setFavTab('viewed_me')} 
                          className={`flex-1 p-4 items-center ${favTab === 'viewed_me' ? 'border-b-2 border-green-500' : ''}`}
                        >
                          <Text className={`font-bold ${favTab === 'viewed_me' ? 'text-green-500' : 'text-gray-400'}`}>👁️ Viewed Me</Text>
                        </TouchableOpacity>
                      </View>

                      {favTab === 'my_likes' && (
                        <FlatList 
                          data={favoriteProfiles} 
                          renderItem={({item}) => (
                            <UserCard 
                              item={item} 
                              onSelect={handleProfileView} 
                              onToggleLike={toggleLike} 
                            />
                          )} 
                          numColumns={2} 
                          keyExtractor={item => item.id} 
                          ListEmptyComponent={
                            <Text className="text-center mt-12 text-gray-400">
                              You haven't liked anyone yet.
                            </Text>
                          }
                        />
                      )}

                      {(favTab === 'liked_me' || favTab === 'viewed_me') && (
                        <View className="flex-1">
                          {isVip || isAdmin ? (
                            <FlatList 
                              data={favTab === 'liked_me' ? likedMeProfiles : viewedMeProfiles} 
                              renderItem={({item}) => (
                                <UserCard 
                                  item={item} 
                                  onSelect={handleProfileView} 
                                  onToggleLike={toggleLike} 
                                />
                              )} 
                              numColumns={2} 
                              keyExtractor={item => item.id}
                              ListEmptyComponent={
                                <Text className="text-center mt-12 text-gray-400">
                                  {favTab === 'liked_me' ? "No likes yet." : "No profile views yet."}
                                </Text>
                              }
                            />
                          ) : (
                            <View className="flex-1 items-center justify-center p-6 bg-gray-50">
                              <Text className="text-6xl mb-4">🔒</Text>
                              <Text className="text-2xl font-black text-black text-center mb-2">Premium Feature</Text>
                              <Text className="text-gray-500 text-center mb-8 font-bold leading-6">
                                {favTab === 'liked_me' 
                                  ? "Subscribe to see everyone who swiped right on you." 
                                  : "Subscribe to see exactly who is looking at your profile in real-time."}
                              </Text>
                              <TouchableOpacity 
                                onPress={() => setShowPaywall(true)} 
                                className="bg-green-500 w-full py-4 rounded-full items-center shadow-lg shadow-green-500/30"
                              >
                                <Text className="text-white font-black text-lg">Unlock VIP Now</Text>
                              </TouchableOpacity>
                            </View>
                          )}
                        </View>
                      )}
                    </View>
                  )}

                  {tab === 'admin' && (
                    <AdminDashboard 
                      profiles={profiles} 
                      setProfiles={setProfiles} 
                      isVip={isVip} 
                      setLobbyMessages={setLobbyMessages}
                      setMessages={setMessages}
                    />
                  )}

                  {tab === 'settings' && (
                    <View className="flex-1 bg-gray-50">
                      <View className="px-4">
                        <InvisibleModeToggle 
                          isPrivate={isPrivate} 
                          toggleInvisibleMode={toggleInvisibleMode} 
                          isVip={isVip} 
                          isAdmin={isAdmin} 
                          setShowPaywall={setShowPaywall} 
                        />
                      </View>

                      {showEditProfile ? (
                        <View className="flex-1 bg-white mt-4 rounded-t-3xl overflow-hidden shadow-lg">
                          <View className="p-4 border-b border-gray-200 bg-gray-50 flex-row items-center shadow-sm z-10">
                            <TouchableOpacity 
                              onPress={() => setShowEditProfile(false)} 
                              className="px-2 py-1"
                            >
                              <Text className="text-green-500 font-black text-[16px]">
                                ← Back to Dashboard
                              </Text>
                            </TouchableOpacity>
                          </View>
                          <EditProfile 
                            myId={myId}             
                            myImage={myImage}       
                            setMyImage={setMyImage} 
                            myName={myName} 
                            setMyName={setMyName}
                            myCity={myCity} 
                            setMyCity={setMyCity}
                            isPrivate={isPrivate} 
                            setIsPrivate={setIsPrivate}
                            notificationsEnabled={notificationsEnabled} 
                            setNotificationsEnabled={setNotificationsEnabled}
                            setShowPaywall={setShowPaywall}
                          />
                        </View>
                      ) : (
                        <View className="flex-1 bg-white mt-4 rounded-t-3xl overflow-hidden shadow-lg">
                          <UserDashboard 
                            myId={myId}             
                            myImage={myImage}       
                            setMyImage={setMyImage} 
                            myName={myName} 
                            myCity={myCity} 
                            isVip={isVip} 
                            isAdmin={isAdmin} 
                            setShowPaywall={setShowPaywall} 
                            openEditProfile={() => setShowEditProfile(true)}
                            receivedGifts={receivedGifts}
                          />
                        </View>
                      )}
                    </View>
                  )}
                </View>

                <View className="h-20 flex-row border-t border-gray-200 bg-white pb-2">
                  {[
                    {id: 'discover', label: 'Explore', icon: '🌍'},
                    {id: 'lobby', label: 'Lobby', icon: '💬'},
                    {id: 'favorites', label: 'Likes', icon: '❤️'},
                    {id: 'settings', label: 'Self', icon: '👤'},
                    ...(isAdmin ? [{id: 'admin', label: 'Mod', icon: '🛠️'}] : []) 
                  ].map((item) => (
                    <TouchableOpacity 
                      key={item.id} 
                      className="flex-1 justify-center items-center" 
                      onPress={() => setTab(item.id as any)}
                    >
                      <Text className="text-[20px]">{item.icon}</Text>
                      <Text className={`text-[10px] font-bold mt-1 ${tab === item.id ? 'text-green-500' : 'text-gray-400'}`}>
                        {item.label}
                      </Text>
                    </TouchableOpacity>
                  ))}
                </View>

                <AllModals 
                  showFilters={showFilters} 
                  setShowFilters={setShowFilters} 
                  filterGender={filterGender} 
                  setFilterGender={setFilterGender} 
                  filterSexuality={filterSexuality} 
                  setFilterSexuality={setFilterSexuality} 
                  SEXUALITIES={SEXUALITIES} 
                  setCurrentPage={setCurrentPage}
                  selectedUser={selectedUser} 
                  setSelectedUser={setSelectedUser} 
                  toggleLike={toggleLike} 
                  profiles={profiles} 
                  setChatUser={setChatUser}
                  chatUser={chatUser} 
                  setChatUserModal={setChatUser} 
                  messages={messages} 
                  setMessages={setMessages} 
                  chatInput={chatInput} 
                  setChatInput={setChatInput} 
                  navigation={navigationRef}
                  handleSendMessage={handleSendMessage}
                  handleStartVideoCall={handleStartVideoCall} 
                  handleAddFriend={handleAddFriend}
                  handleSendGift={handleSendGift} 
                  myId={myId} 
                  myImage={myImage} // 🚀 FIXED: IMAGE PASSED TO MODALS (Line 1025)
                  isAdmin={isAdmin}
                  isVip={isVip}
                  setShowPaywall={setShowPaywall}
                  totalFreeMessages={totalFreeMessages} 
                  setTotalFreeMessages={setTotalFreeMessages}
                />

                <Subscription 
                  showPaywall={showPaywall} 
                  setShowPaywall={setShowPaywall} 
                  handlePayment={handlePayment} 
                  isAdmin={isAdmin} 
                />
              </SafeAreaView>
            );
          }}
        </Stack.Screen>

        <Stack.Screen name="CloudflareVideoCall" component={CloudflareVideoCall} />

      </Stack.Navigator>
    </NavigationContainer>
    </SafeAreaProvider> 
  );
}