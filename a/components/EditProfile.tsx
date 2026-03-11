import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, TouchableOpacity, ScrollView, Image, Alert, Switch, Modal, FlatList, ActivityIndicator } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';

import { DeleteAccountButton } from './DeleteAccountButton'; 

const API_URL = "http://10.0.2.2:3001"; 

const HERE_FOR_OPTIONS = ["Dating", "Romance", "Friendship", "Networking", "Something Else"];
const SEXUALITY_OPTIONS = ["Heterosexual", "Bisexual", "Lesbian", "Gay", "Other"];
const MUSIC_OPTIONS = ["Dance", "Electronic", "Jazz", "Rock", "Pop", "Classical", "Hip-hop", "Metal", "R&B", "Country", "Other"];
const EDUCATION_OPTIONS = ["No Education", "High School", "In College", "Undergraduate Degree", "Master's", "PhD", "Other"];
const BODY_TYPE_OPTIONS = ["Athletic", "Fat", "Normal", "Slim", "Muscular", "Curvy", "Other"];
const HAIR_OPTIONS = ["Black", "Brown", "Blonde", "Red", "Grey", "Bald", "Other"];
const EYE_OPTIONS = ["Brown", "Blue", "Green", "Hazel", "Grey", "Other"];

const COUNTRY_OPTIONS = [
  "USA", "UK", "Canada", "Australia", "Serbia", "Croatia", "Bosnia", "Montenegro", "Macedonia", "Slovenia",
  "Germany", "France", "Italy", "Spain", "Portugal", "Netherlands", "Belgium", "Switzerland", "Austria", "Sweden",
  "Norway", "Denmark", "Finland", "Ireland", "Poland", "Greece", "Turkey", "Russia", "Ukraine", "Romania",
  "Bulgaria", "Hungary", "Czech Republic", "Slovakia", "Japan", "South Korea", "China", "India", "Brazil", "Argentina",
  "Colombia", "Chile", "Mexico", "South Africa", "Egypt", "Morocco", "Nigeria", "Kenya", "New Zealand", "Other"
];

const CITY_OPTIONS = [
  "Belgrade", "Novi Sad", "Subotica", "Nis", "Kragujevac", "Zagreb", "Split", "Sarajevo", "Banja Luka", "Podgorica",
  "Skopje", "Ljubljana", "London", "Manchester", "New York", "Los Angeles", "Chicago", "Miami", "Toronto", "Vancouver",
  "Sydney", "Melbourne", "Berlin", "Munich", "Paris", "Lyon", "Rome", "Milan", "Madrid", "Barcelona",
  "Amsterdam", "Vienna", "Zurich", "Stockholm", "Oslo", "Copenhagen", "Dublin", "Warsaw", "Athens", "Istanbul",
  "Moscow", "Kyiv", "Tokyo", "Seoul", "Beijing", "Mumbai", "Sao Paulo", "Buenos Aires", "Mexico City", "Other"
];

const HEIGHT_OPTIONS = Array.from({length: 81}, (_, i) => `${i + 140} cm`); 
const WEIGHT_OPTIONS = Array.from({length: 111}, (_, i) => `${i + 40} kg`); 
const DAYS = Array.from({length: 31}, (_, i) => `${i + 1}`);
const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
const YEARS = Array.from({length: 70}, (_, i) => `${2006 - i}`);

export const EditProfile = ({ 
  myId,             
  myImage,          
  setMyImage,       
  myName, setMyName, 
  myCity, setMyCity, 
  isPrivate, setIsPrivate, 
  notificationsEnabled, setNotificationsEnabled, 
  setShowPaywall,
  refreshUserData 
}: any) => {
  
  const currentUserId = myId; 

  const [bio, setBio] = useState('');
  const [hereFor, setHereFor] = useState('Dating');
  const [country, setCountry] = useState('Serbia');
  const [music, setMusic] = useState('Electronic');
  const [education, setEducation] = useState('High School');
  const [sexuality, setSexuality] = useState('Heterosexual');
  const [bodyType, setBodyType] = useState('Normal');
  const [hairColor, setHairColor] = useState('Brown');
  const [eyeColor, setEyeColor] = useState('Brown');
  const [weight, setWeight] = useState('75 kg');
  const [height, setHeight] = useState('180 cm');
  const [day, setDay] = useState('1');
  const [month, setMonth] = useState('January');
  const [year, setYear] = useState('2000');

  const [avatarUrl, setAvatarUrl] = useState(myImage || 'https://via.placeholder.com/150');
  const [isUploading, setIsUploading] = useState(false);
  const [isLoadingProfile, setIsLoadingProfile] = useState(true);

  const [pickerVisible, setPickerVisible] = useState(false);
  const [pickerData, setPickerData] = useState<string[]>([]);
  const [pickerTitle, setPickerTitle] = useState('');
  const [currentField, setCurrentField] = useState('');

  const [showBlockedModal, setShowBlockedModal] = useState(false);
  const [blockedUsers, setBlockedUsers] = useState<any[]>([]);

  useEffect(() => {
    const fetchMyProfileData = async () => {
      try {
        const res = await fetch(`${API_URL}/api/users`);
        if (res.ok) {
          const users = await res.json();
          const myData = users.find((u: any) => u.id === currentUserId);
          
          if (myData) {
            if (myData.bio) setBio(myData.bio);
            if (myData.here_for) setHereFor(myData.here_for);
            if (myData.country) setCountry(myData.country);
            if (myData.music) setMusic(myData.music);
            if (myData.education) setEducation(myData.education);
            if (myData.sexuality) setSexuality(myData.sexuality);
            if (myData.body_type) setBodyType(myData.body_type);
            if (myData.hair_color) setHairColor(myData.hair_color);
            if (myData.eye_color) setEyeColor(myData.eye_color);
            if (myData.weight) setWeight(myData.weight);
            if (myData.height) setHeight(myData.height);
            if (myData.dob_day) setDay(myData.dob_day);
            if (myData.dob_month) setMonth(myData.dob_month);
            if (myData.dob_year) setYear(myData.dob_year);
          }
        }
      } catch (error) {
        console.error("Failed to fetch initial profile data:", error);
      } finally {
        setIsLoadingProfile(false);
      }
    };

    fetchMyProfileData();
    if (myImage) setAvatarUrl(myImage);
  }, [currentUserId, myImage]);

  const openPicker = (title: string, data: string[], field: string) => {
    setPickerTitle(title);
    setPickerData(data);
    setCurrentField(field);
    setPickerVisible(true);
  };

  const handleSelect = (item: string) => {
    if (currentField === 'hereFor') setHereFor(item);
    if (currentField === 'music') setMusic(item);
    if (currentField === 'education') setEducation(item);
    if (currentField === 'sexuality') setSexuality(item);
    if (currentField === 'bodyType') setBodyType(item);
    if (currentField === 'country') setCountry(item);
    if (currentField === 'city') setMyCity(item);
    if (currentField === 'hair') setHairColor(item);
    if (currentField === 'eye') setEyeColor(item);
    if (currentField === 'height') setHeight(item);
    if (currentField === 'weight') setWeight(item);
    if (currentField === 'day') setDay(item);
    if (currentField === 'month') setMonth(item);
    if (currentField === 'year') setYear(item);
    setPickerVisible(false);
  };

  const handleImageUpload = async () => {
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
    
    if (permissionResult.granted === false) {
      Alert.alert("Permission Required", "Allow access to photos to change your profile picture.");
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'], 
      allowsEditing: true,
      aspect: [1, 1],
      quality: 1,
    });

    if (!result.canceled && result.assets && result.assets.length > 0) {
      setIsUploading(true);
      try {
        const manipResult = await ImageManipulator.manipulateAsync(
          result.assets[0].uri,
          [{ resize: { width: 500 } }],
          { compress: 0.7, format: ImageManipulator.SaveFormat.WEBP }
        );

        const response = await fetch(`${API_URL}/api/get-upload-url`);
        if (!response.ok) throw new Error(`Backend failed with status: ${response.status}`);

        const { uploadUrl, publicUrl } = await response.json();
        if (!uploadUrl) throw new Error("Backend did not return an uploadUrl");

        const imageResponse = await fetch(manipResult.uri);
        const blob = await imageResponse.blob();
        
        const uploadRes = await fetch(uploadUrl, {
          method: 'PUT',
          body: blob,
          headers: { 'Content-Type': 'image/webp' },
        });

        if (uploadRes.ok) {
          setAvatarUrl(publicUrl);
          if (setMyImage) setMyImage(publicUrl); 

          await fetch(`${API_URL}/api/users/update-image`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ userId: currentUserId, imageUrl: publicUrl })
          });

          if (refreshUserData) refreshUserData();

          Alert.alert("Looking Good!", "Profile picture successfully updated.");
        } else {
          Alert.alert("Upload Rejected", "Cloudflare blocked the file.");
        }
      } catch (error: any) {
        Alert.alert("Upload Failed", error.message || "Could not update profile picture.");
      } finally {
        setIsUploading(false);
      }
    }
  };

  const handleSaveProfile = async () => {
    try {
      const res = await fetch(`${API_URL}/api/users/update-profile`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId: currentUserId,
          name: myName,
          bio: bio,
          hereFor: hereFor,
          city: myCity,
          country: country,
          music: music,
          education: education,
          sexuality: sexuality,
          bodyType: bodyType,
          hairColor: hairColor,
          eyeColor: eyeColor,
          weight: weight,
          height: height,
          day: day,
          month: month,
          year: year
        })
      });

      if (res.ok) {
        Alert.alert("Saved!", "Your profile has been updated.");
        if (refreshUserData) {
          refreshUserData();
        }
      } else {
        Alert.alert("Error", "Failed to update profile in database.");
      }
    } catch (e) {
      Alert.alert("Network Error", "Could not connect to the server.");
    }
  };

  const openBlockedUsers = async () => {
    setShowBlockedModal(true);
    try {
      const res = await fetch(`${API_URL}/api/blocks/${currentUserId}`);
      if (res.ok) {
        const data = await res.json();
        setBlockedUsers(data);
      }
    } catch (e) {
      console.error("Failed to fetch blocked users");
    }
  };

  const handleUnblock = async (blockedId: string) => {
    try {
      const res = await fetch(`${API_URL}/api/unblock`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ blockerId: currentUserId, blockedId })
      });
      if (res.ok) {
        setBlockedUsers(prev => prev.filter(u => u.id !== blockedId));
        Alert.alert("Unblocked", "This person has been removed from your block list.");
      }
    } catch (e) {
      Alert.alert("Error", "Could not unblock user.");
    }
  };

  if (isLoadingProfile) {
    return (
      <View className="flex-1 justify-center items-center">
        <ActivityIndicator size="large" color="#4CAF50" />
        <Text className="mt-4 text-gray-500">Loading your profile data...</Text>
      </View>
    );
  }

  return (
    <View className="flex-1">
      <ScrollView className="p-5">
        
        <View className="items-center mb-7">
          <TouchableOpacity onPress={handleImageUpload} className="items-center" disabled={isUploading}>
            {isUploading ? (
              <View className="w-[120px] h-[120px] rounded-full mb-2.5 bg-gray-200 items-center justify-center border-2 border-[#EEE]">
                <ActivityIndicator size="large" color="#4CAF50" />
              </View>
            ) : (
              <View className="relative">
                <Image source={{uri: avatarUrl}} className="w-[120px] h-[120px] rounded-full mb-2.5 border-2 border-[#EEE]" />
                <View className="absolute bottom-2 right-0 bg-[#4CAF50] w-10 h-10 rounded-full items-center justify-center border-2 border-white shadow-md elevation-3">
                  <Text className="text-white text-[16px]">📷</Text>
                </View>
              </View>
            )}
            
            <Text className="text-[#4CAF50] font-bold mt-2 text-[16px]">
              {isUploading ? "Uploading to Cloud & DB..." : "Change Picture"}
            </Text>
          </TouchableOpacity>
        </View>
        
        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Display Name</Text>
        <TextInput className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] text-black" value={myName} onChangeText={setMyName} placeholder="Enter your name" placeholderTextColor="#999" />
        
        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Bio / About Me</Text>
        <TextInput 
          className="h-[100px] bg-[#FFF] rounded-[10px] p-[15px] border border-[#DDD] mx-[15px] mb-[10px] text-black" 
          value={bio} 
          onChangeText={setBio} 
          placeholder="Write something about yourself..." 
          placeholderTextColor="#999"
          multiline={true}
          numberOfLines={4}
          style={{ textAlignVertical: 'top' }}
        />

        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Looking For (Here For)</Text>
        <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Looking For', HERE_FOR_OPTIONS, 'hereFor')}>
          <Text className="text-[#333] text-[14px]">{hereFor}</Text>
        </TouchableOpacity>

        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Date of Birth (Calculates Age)</Text>
        <View className="flex-row justify-between items-center">
          <TouchableOpacity className="flex-1 h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Day', DAYS, 'day')}>
            <Text className="text-[#333] text-[14px]">{day}</Text>
          </TouchableOpacity>
          <TouchableOpacity className="flex-1 h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Month', MONTHS, 'month')}>
            <Text className="text-[#333] text-[14px]">{month}</Text>
          </TouchableOpacity>
          <TouchableOpacity className="flex-1 h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Year', YEARS, 'year')}>
            <Text className="text-[#333] text-[14px]">{year}</Text>
          </TouchableOpacity>
        </View>

        <View className="flex-row justify-between items-center">
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Country</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Country', COUNTRY_OPTIONS, 'country')}>
              <Text className="text-[#333] text-[14px]" numberOfLines={1}>{country}</Text>
            </TouchableOpacity>
          </View>
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Town / City</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Town / City', CITY_OPTIONS, 'city')}>
              <Text className="text-[#333] text-[14px]" numberOfLines={1}>{myCity}</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View className="flex-row justify-between items-center">
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Sexuality</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Sexuality', SEXUALITY_OPTIONS, 'sexuality')}>
              <Text className="text-[#333] text-[14px]">{sexuality}</Text>
            </TouchableOpacity>
          </View>
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Music</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Music', MUSIC_OPTIONS, 'music')}>
              <Text className="text-[#333] text-[14px]">{music}</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View className="flex-row justify-between items-center">
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Body Type</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Body Type', BODY_TYPE_OPTIONS, 'bodyType')}>
              <Text className="text-[#333] text-[14px]">{bodyType}</Text>
            </TouchableOpacity>
          </View>
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Education Level</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Education', EDUCATION_OPTIONS, 'education')}>
              <Text className="text-[#333] text-[14px]" numberOfLines={1}>{education}</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View className="flex-row justify-between items-center">
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Height</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Height', HEIGHT_OPTIONS, 'height')}>
              <Text className="text-[#333] text-[14px]">{height}</Text>
            </TouchableOpacity>
          </View>
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Weight</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Weight', WEIGHT_OPTIONS, 'weight')}>
              <Text className="text-[#333] text-[14px]">{weight}</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View className="flex-row justify-between items-center">
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Hair Color</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Hair Color', HAIR_OPTIONS, 'hair')}>
              <Text className="text-[#333] text-[14px]">{hairColor}</Text>
            </TouchableOpacity>
          </View>
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Eye Color</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Eye Color', EYE_OPTIONS, 'eye')}>
              <Text className="text-[#333] text-[14px]">{eyeColor}</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View className="flex-row justify-between items-center my-4 pb-4 border-b border-[#F5F5F5] px-[15px]">
          <View>
            <Text className="text-[#333] font-bold text-[16px]">Global Notifications</Text>
            <Text className="text-[12px] text-[#999]">Alerts for matches and lobby</Text>
          </View>
          <Switch value={notificationsEnabled} onValueChange={setNotificationsEnabled} trackColor={{true: '#4CAF50'}} />
        </View>

        <TouchableOpacity className="bg-[#4CAF50] p-[18px] rounded-[150px] items-center m-[15px]" onPress={handleSaveProfile}>
          <Text className="text-white font-bold">Save Profile Changes</Text>
        </TouchableOpacity>

        <TouchableOpacity className="bg-red-50 p-[18px] rounded-[150px] items-center mx-[15px] mb-[15px] border border-red-200" onPress={openBlockedUsers}>
          <Text className="text-red-600 font-bold">🚫 Manage Blocked Users</Text>
        </TouchableOpacity>

        <TouchableOpacity className="bg-black p-[18px] rounded-[150px] items-center mx-[15px] mb-[15px]" onPress={() => setShowPaywall(true)}>
          <Text className="text-white font-bold">Manage VIP Subscription</Text>
        </TouchableOpacity>

        <DeleteAccountButton 
          userId={currentUserId} 
          onSuccess={() => {
            console.log("User deleted themselves, redirecting to login...");
          }} 
        />

      </ScrollView>

      <Modal visible={pickerVisible} animationType="slide" transparent={true}>
        <View className="flex-1 bg-black/60 justify-end">
          <View className="bg-white rounded-t-[20px] max-h-[50%]">
            <View className="flex-row justify-between p-5 border-b border-[#EEE] items-center">
              <Text className="text-[18px] font-bold text-[#333]">Select {pickerTitle}</Text>
              <TouchableOpacity onPress={() => setPickerVisible(false)}>
                <Text className="text-[24px] text-[#333]">✕</Text>
              </TouchableOpacity>
            </View>
            <FlatList 
              data={pickerData}
              keyExtractor={(item, index) => index.toString()}
              renderItem={({item}) => (
                <TouchableOpacity className="p-[18px] border-b border-[#EEE]" onPress={() => handleSelect(item)}>
                  <Text className="text-[16px] text-center text-black">{item}</Text>
                </TouchableOpacity>
              )}
            />
          </View>
        </View>
      </Modal>

      <Modal visible={showBlockedModal} animationType="slide" transparent={true}>
        <View className="flex-1 bg-black/60 justify-end">
          <View className="bg-white rounded-t-[24px] h-[70%] p-5 pb-10">
            <View className="flex-row justify-between items-center mb-4 border-b border-gray-100 pb-4">
              <Text className="text-[20px] font-black text-gray-800">🚫 Blocked Accounts</Text>
              <TouchableOpacity onPress={() => setShowBlockedModal(false)}>
                <Text className="text-[24px] text-gray-400 font-bold">✕</Text>
              </TouchableOpacity>
            </View>

            {blockedUsers.length === 0 ? (
              <Text className="text-center text-gray-400 font-bold mt-10 text-lg">You haven't blocked anyone.</Text>
            ) : (
              <FlatList 
                data={blockedUsers}
                keyExtractor={(item) => item.id.toString()}
                renderItem={({item}) => (
                  <View className="flex-row items-center justify-between p-4 mb-2 bg-gray-50 rounded-2xl border border-gray-100">
                    <View className="flex-row items-center flex-1">
                      <Image source={{uri: item.image}} className="w-[45px] h-[45px] rounded-full mr-3 border border-gray-200" />
                      <Text className="font-bold text-gray-800 text-[16px] flex-shrink" numberOfLines={1}>{item.name}</Text>
                    </View>
                  </View>
                )}
              />
            )}
          </View>
        </View>
      </Modal>

    </View>
  );
};