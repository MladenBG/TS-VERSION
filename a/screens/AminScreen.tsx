import React from 'react';
import { View, Text, TextInput, ScrollView, Image, TouchableOpacity } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';

export const AdminScreen = ({ profiles, adminSearch, setAdminSearch, onToggleBan }: any) => {
  // Filter the profiles based on the search query
  const filtered = profiles.filter((p: any) => 
    p.name.toLowerCase().includes(adminSearch.toLowerCase())
  );

  return (
    <SafeAreaView className="flex-1 bg-gray-50">
      
      {/* HEADER SECTION */}
      <View className="p-6 bg-white border-b border-gray-200 z-10 shadow-sm">
        <Text className="text-3xl font-black text-gray-900 mb-4 tracking-tight">
          Admin Portal
        </Text>
        
        {/* MODERN SEARCH INPUT */}
        <View className="w-full h-12 bg-gray-100 rounded-xl flex-row items-center px-4">
          <Feather name="search" size={18} color="#9CA3AF" />
          <TextInput 
            className="flex-1 ml-3 font-bold text-gray-900 h-full" 
            placeholder="Search User Name..." 
            placeholderTextColor="#9CA3AF"
            value={adminSearch}
            onChangeText={setAdminSearch}
            autoCapitalize="none"
            autoCorrect={false}
          />
        </View>
      </View>

      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        
        {/* STATS DASHBOARD */}
        <View className="flex-row p-4 justify-between mt-2">
          <View className="flex-1 bg-white p-5 rounded-2xl shadow-sm mr-2 items-center border border-gray-100">
            <Text className="text-3xl font-black text-gray-900">{profiles.length}</Text>
            <Text className="text-[10px] font-black text-gray-400 mt-1 uppercase tracking-wider">
              Total Users
            </Text>
          </View>
          
          <View className="flex-1 bg-white p-5 rounded-2xl shadow-sm ml-2 items-center border border-gray-100">
            <Text className="text-3xl font-black text-red-500">
              {profiles.filter((p: any) => p.isBanned).length}
            </Text>
            <Text className="text-[10px] font-black text-gray-400 mt-1 uppercase tracking-wider">
              Banned Users
            </Text>
          </View>
        </View>

        {/* USERS LIST */}
        <View className="px-4 pb-10 mt-2">
          {filtered.slice(0, 50).map((u: any) => (
            <View 
              key={u.id} 
              className="flex-row items-center bg-white p-4 mb-3 rounded-2xl shadow-sm border border-gray-100"
            >
              <Image 
                source={{ uri: u.image }} 
                className="w-14 h-14 rounded-full mr-4 bg-gray-200" 
              />
              
              <View className="flex-1 justify-center">
                <Text 
                  className={`font-black text-lg mb-0.5 ${u.isBanned ? 'text-red-400 line-through' : 'text-gray-900'}`}
                >
                  {u.name}
                </Text>
                <Text className="text-xs font-bold text-gray-400">
                  {u.town}
                </Text>
              </View>
              
              <TouchableOpacity 
                onPress={() => onToggleBan(u.id)}
                activeOpacity={0.7}
                className={`px-4 py-2.5 rounded-full border ${
                  u.isBanned 
                    ? 'bg-green-50 border-green-200' 
                    : 'bg-red-50 border-red-200'
                }`}
              >
                <Text 
                  className={`font-black text-[11px] tracking-wider ${
                    u.isBanned ? 'text-green-600' : 'text-red-600'
                  }`}
                >
                  {u.isBanned ? 'UNBAN' : 'BAN'}
                </Text>
              </TouchableOpacity>
            </View>
          ))}

          {/* EMPTY STATE */}
          {filtered.length === 0 && (
            <View className="items-center justify-center mt-10">
              <Feather name="users" size={40} color="#D1D5DB" />
              <Text className="text-gray-400 font-bold mt-4">No users found.</Text>
            </View>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};