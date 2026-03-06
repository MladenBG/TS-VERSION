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
  Vibration
} from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createNavigationContainerRef } from '@react-navigation/native';
import io from 'socket.io-client';

// IMPORTING FULL DATA AND COMPONENTS
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

// IMPORTING SEPARATED COMPONENTS
import { Lobby } from './components/Lobby';
import { HeaderSwipe } from './components/HeaderSwipe';
import { SwipeButton } from './components/SwipeButton';
import { Subscription } from './components/Subscription';
import { EditProfile } from './components/EditProfile';
import { UserDashboard } from './components/UserDashboard';
import { AdminDashboard } from './components/AdminDashboard';
import { VideoCall } from './components/VideoCall';
import { Inbox } from './components/Inbox';
import { InvisibleModeToggle } from './components/InvisibleModeToggle';

// AUTH SCREENS
import { HomeScreen } from './screens/HomeScreen';
import { LoginScreen } from './screens/LoginScreen';
import { SignUpScreen } from './screens/SignUpScreen';

// This allows the app to actually use the provider
import { SafeAreaView, SafeAreaProvider } from 'react-native-safe-area-context';

const logoImg = require('./assets/logo.png');
const socket = io("http://localhost:3000");
const Stack = createStackNavigator();

export const navigationRef = createNavigationContainerRef();

export default function App() {
  const [tab, setTab] = useState<'discover' | 'lobby' | 'favorites' | 'admin' | 'settings' | 'inbox'>('discover');
  const [favTab, setFavTab] = useState<'my_likes' | 'liked_me' | 'viewed_me'>('my_likes');

  const [discoveryMode, setDiscoveryMode] = useState<'list' | 'swipe' | 'radar'>('list');
  const [showPaywall, setShowPaywall] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [showEditProfile, setShowEditProfile] = useState(false);
  
  const [isAdmin, setIsAdmin] = useState(true); 
  const [isVip, setIsVip] = useState(false);

  const [messageCount, setMessageCount] = useState(0);
  const [lastResetDate, setLastResetDate] = useState(Date.now());
  
  const [profiles, setProfiles] = useState<any[]>([]);
  const [likedMeProfiles, setLikedMeProfiles] = useState<any[]>([]);
  const [viewedMeProfiles, setViewedMeProfiles] = useState<any[]>([]);
  
  // 🚀 GIFTS STATE 🚀
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

  useEffect(() => {
    const fetchRealUsers = async () => {
      try {
        const res = await fetch('http://10.0.2.2:3000/api/users');
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
            isBanned: false
          }));
          setProfiles(formattedProfiles);
        }

        const likedRes = await fetch('http://10.0.2.2:3000/api/likes/who-liked-me');
        const likedData = await likedRes.json();
        if (!likedData.error) setLikedMeProfiles(likedData);

        const viewsRes = await fetch('http://10.0.2.2:3000/api/views');
        const viewsData = await viewsRes.json();
        if (!viewsData.error) setViewedMeProfiles(viewsData);

        // 🚀 FETCH PRIVATE GIFTS 🚀
        const giftsRes = await fetch('http://10.0.2.2:3000/api/gifts');
        const giftsData = await giftsRes.json();
        if (!giftsData.error) setReceivedGifts(giftsData);

      } catch (error) {
        console.error("Failed to load data:", error);
      }
    };

    fetchRealUsers();
  }, []);

  useEffect(() => {
    if (chatUser) {
      const fetchChatHistory = async () => {
        try {
          const res = await fetch(`http://10.0.2.2:3000/api/messages?other_id=${chatUser.id}`);
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
  }, [chatUser]);

  useEffect(() => {
    currentTab.current = tab;
    if (tab === 'inbox') {
      setUnreadCount(0);
    }
  }, [tab]);

  const playNotificationSound = async () => { Vibration.vibrate(); };

  const [swipeIndex, setSwipeIndex] = useState(0);
  const position = useRef(new Animated.ValueXY()).current;

  const [lobbyMessages, setLobbyMessages] = useState([
    { id: '1', user: 'Luka 9', text: 'Hey from Budva!', time: '12:00' },
    { id: '2', user: 'Emma 2', text: 'Anyone in Miami?', time: '12:05' },
    { id: '3', user: 'System', text: 'Welcome to Dateroot Global.', time: '12:10' },
  ]);
  const [lobbyInput, setLobbyInput] = useState('');

  const [myName, setMyName] = useState('New User');
  const [myCity, setMyCity] = useState('Budva');
  
  const [isPrivate, setIsPrivate] = useState(false); 
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);

  const toggleInvisibleMode = async (newValue: boolean) => {
    setIsPrivate(newValue); 
    try {
      await fetch('http://10.0.2.2:3000/api/settings/invisible', {
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

  useEffect(() => {
    const handleReceive = (msg: any) => {
      setLobbyMessages(prev => [msg, ...prev]);
    };

    socket.on("receive_lobby_msg", handleReceive);
    
    return () => { 
      socket.off("receive_lobby_msg", handleReceive); 
    };
  }, []);

  useEffect(() => {
    let ghostTimer: any;

    const scheduleGhostMessage = () => {
      const min = 30 * 60 * 1000;
      const max = 120 * 60 * 1000;
      const delay = Math.floor(Math.random() * (max - min + 1) + min);

      ghostTimer = setTimeout(() => {
        const randomProfile = ALL_PROFILES[Math.floor(Math.random() * ALL_PROFILES.length)];
        const randomText = [
          "Hey there! 👋", 
          "Wow, great profile!", 
          "Are you from around here?", 
          "Hi! 😊",
          "What are you up to today?"
        ][Math.floor(Math.random() * 5)];
        
        const newMsg = {
          id: Date.now().toString(),
          text: randomText,
          sender: 'them'
        };

        setMessages(prev => ({
          ...prev,
          [randomProfile.id]: [...(prev[randomProfile.id] || []), newMsg]
        }));
        
        if (currentTab.current !== 'inbox') {
          setUnreadCount(prev => prev + 1);
          playNotificationSound();
        }

        scheduleGhostMessage();
      }, delay);
    };

    scheduleGhostMessage();
    
    return () => clearTimeout(ghostTimer);
  }, []);

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
      await fetch('http://10.0.2.2:3000/api/views', {
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
      await fetch('http://10.0.2.2:3000/api/likes', {
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
      setMessageCount(0); 
      setLastResetDate(Date.now());
      return true; 
    }

    if (messageCount >= 4) {
      Alert.alert("Out of Free Messages", "You used your 4 free messages. Subscribe to continue chatting, or wait 5 days!");
      setShowPaywall(true);
      return false; 
    }

    setMessageCount(prev => prev + 1);
    return true;
  };

  const handleSendMessage = async () => {
    if (!chatInput.trim() || !chatUser) return;
    
    if (!checkMessageLimits()) return;
    
    const textToSend = chatInput;
    setChatInput('');

    const newMsg = { 
      id: Date.now().toString(), 
      text: textToSend, 
      sender: 'me' 
    };
    
    setMessages(prev => ({ 
      ...prev, 
      [chatUser.id]: [...(prev[chatUser.id] || []), newMsg] 
    }));
    
    try {
      await fetch('http://10.0.2.2:3000/api/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ receiver_id: chatUser.id, content: textToSend })
      });
    } catch (error) {
      console.error("Database connection failed for message:", error);
    }
  };

  const sendLobbyMessage = () => {
    if (!lobbyInput.trim()) return;

    if (!checkMessageLimits()) return;
    
    const msg = { 
      id: Date.now().toString(), 
      user: myName, 
      text: lobbyInput, 
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) 
    };
    
    socket.emit("send_lobby_msg", msg);
    setLobbyMessages(prev => [msg, ...prev]);
    setLobbyInput('');
  };

  const handleStartVideoCall = (user: any) => {
    if (!isAdmin && !isVip) {
      Alert.alert("Premium Feature", "Video Calling is locked. You must subscribe to use the camera!");
      setShowPaywall(true);
      return;
    }
    if (navigationRef.isReady()) {
      (navigationRef as any).navigate('VideoCall', { user });
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
      await fetch('http://10.0.2.2:3000/api/friends', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ friend_id: user.id })
      });
    } catch (error) {
      console.error("Failed to add friend:", error);
    }
  };

  // 🚀 HANDLE SEND GIFT 🚀
  const handleSendGift = async (user: any, giftName: string) => {
    if (!isAdmin && !isVip) {
      Alert.alert("Premium Feature", "Sending gifts is a VIP exclusive feature. Subscribe to stand out!");
      setShowPaywall(true);
      return;
    }

    Alert.alert("Gift Sent!", `You sent a ${giftName} to ${user.name}!`);
    
    try {
      await fetch('http://10.0.2.2:3000/api/gifts', {
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
          {({ navigation }: any) => {

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
                  {/* DISCOVER TAB */}
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
                    />
                  )}

                  {/* LIKES & VIEWS TAB */}
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

                      {/* PAYWALLED TABS */}
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
                          {/* 🚀 PASSING receivedGifts TO DASHBOARD 🚀 */}
                          <UserDashboard 
                            myName={myName} 
                            myCity={myCity} 
                            isVip={isVip} 
                            setShowPaywall={setShowPaywall} 
                            openEditProfile={() => setShowEditProfile(true)}
                            receivedGifts={receivedGifts} 
                          />
                        </View>
                      )}
                    </View>
                  )}
                </View>

                {/* DYNAMIC BOTTOM NAV BAR */}
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
                  chatInput={chatInput} 
                  setChatInput={setChatInput} 
                  navigation={navigationRef}
                  handleSendMessage={handleSendMessage}
                  handleStartVideoCall={handleStartVideoCall} 
                  handleAddFriend={handleAddFriend}
                  handleSendGift={handleSendGift} 
                />

                <Subscription 
                  showPaywall={showPaywall} 
                  setShowPaywall={setShowPaywall} 
                  handlePayment={handlePayment} 
                />
              </SafeAreaView>
            );
          }}
        </Stack.Screen>
        <Stack.Screen name="VideoCall" component={VideoCall} />
      </Stack.Navigator>
    </NavigationContainer>
    </SafeAreaProvider> 
  );
}