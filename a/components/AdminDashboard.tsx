import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, ScrollView, Image, TouchableOpacity, Alert } from 'react-native';

// =========================================================================
// 🚨 THE MASTER URL SWITCH 🚨
// =========================================================================
// USE NGROK FOR BOTH EMULATOR AND PHONE AT THE SAME TIME:
//const API_URL = "https://marshall-voltametric-clair.ngrok-free.dev"; 
//const API_URL = "https://jn6hwd5g-3000.euw.devtunnels.ms";
// COMMENT OUT THE LOCAL IP:
const API_URL = "http://10.0.2.2:3000"; 
// =========================================================================

export const AdminDashboard = ({ profiles, setProfiles, isVip, setLobbyMessages, setMessages }: any) => {
  const [adminSearch, setAdminSearch] = useState('');
  const [viewMode, setViewMode] = useState<'users' | 'reports'>('users');
  const [reports, setReports] = useState<any[]>([]);

  // 🚀 FETCH LIVE REPORTS FROM DATABASE
  const fetchReports = async () => {
    try {
      const res = await fetch(`${API_URL}/api/admin/reports`);
      if (res.ok) {
        const data = await res.json();
        setReports(data);
      }
    } catch (e) {
      console.error("Could not fetch reports", e);
    }
  };

  useEffect(() => {
    if (viewMode === 'reports') {
      fetchReports();
    }
  }, [viewMode]);

  const handleResolveReport = async (reportId: number) => {
    try {
      await fetch(`${API_URL}/api/admin/resolve-report`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reportId })
      });
      setReports(prev => prev.filter(r => r.id !== reportId));
      Alert.alert("Resolved", "Report has been cleared.");
    } catch (e) {
      Alert.alert("Error", "Could not resolve report.");
    }
  };

  // 🚀 REAL ADMIN ACTIONS HIT THE DATABASE 🚀
  const executeAdminAction = async (action: string, target_id: string | null = null, successMessage: string) => {
    try {
      const res = await fetch(`${API_URL}/api/admin/action`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, target_id })
      });
      
      const data = await res.json();
      
      if (!data.error) {
        Alert.alert("Success", successMessage);
        
        // 🚀 INSTANT UI WIPES (No refresh needed!)
        if (action === 'wipe_lobby' && setLobbyMessages) {
          setLobbyMessages([]); 
        }
        if (action === 'wipe_private' && setMessages) {
          setMessages({}); 
        }

        // UI Updates for banning
        if (action === 'ban_user' || action === 'block_ip') {
          setProfiles((prev: any[]) => prev.map((p: any) => 
            p.id === target_id ? { ...p, isBanned: true } : p
          ));
        }
        
        // UI Updates for unbanning
        if (action === 'unban_user' || action === 'unblock_ip') {
          setProfiles((prev: any[]) => prev.map((p: any) => 
            p.id === target_id ? { ...p, isBanned: false } : p
          ));
        }

      } else {
        Alert.alert("Error", data.error);
      }
    } catch (error) {
      console.error("Admin action failed:", error);
      Alert.alert("Error", "Could not reach the database.");
    }
  };

  // 🚨 NUKE CONFIRMATION DIALOGS
  const handleWipeLobby = () => {
    Alert.alert("☢️ WIPE LOBBY", "Are you sure? This deletes ALL public messages permanently.", [
      { text: "Cancel", style: "cancel" },
      { text: "Wipe It", style: "destructive", onPress: () => executeAdminAction('wipe_lobby', null, "Lobby completely cleared.") }
    ]);
  };

  const handleWipePrivateChats = () => {
    Alert.alert("☢️ WIPE PRIVATE CHATS", "Are you sure? This deletes ALL private DMs between EVERY user in the app.", [
      { text: "Cancel", style: "cancel" },
      { text: "Wipe Everything", style: "destructive", onPress: () => executeAdminAction('wipe_private', null, "All private chats deleted.") }
    ]);
  };

  // 🚨 BAN / UNBAN CONTROLS
  const handleBanUser = (user: any) => {
    Alert.alert("Ban User", `Are you sure you want to ban ${user.name}?`, [
      { text: "Cancel", style: "cancel" },
      { text: "Ban", style: "destructive", onPress: () => executeAdminAction('ban_user', user.id, `${user.name} has been banned.`) }
    ]);
  };

  const handleIpBlockUser = (user: any) => {
    Alert.alert("🚫 IP BLOCK USER", `Ban ${user.name} and block their IP address permanently?`, [
      { text: "Cancel", style: "cancel" },
      { text: "IP BLOCK", style: "destructive", onPress: () => executeAdminAction('block_ip', user.id, `${user.name} is banned and their IP is blacklisted.`) }
    ]);
  };

  const handleUnbanUser = (user: any) => {
    Alert.alert("Unban User", `Remove ban for ${user.name}?`, [
      { text: "Cancel", style: "cancel" },
      { text: "Unban", style: "default", onPress: () => executeAdminAction('unban_user', user.id, `${user.name} has been unbanned.`) }
    ]);
  };

  const handleUnblockIpUser = (user: any) => {
    Alert.alert("Remove IP Block", `Unban ${user.name} and remove their IP from the blacklist?`, [
      { text: "Cancel", style: "cancel" },
      { text: "Unblock IP", style: "default", onPress: () => executeAdminAction('unblock_ip', user.id, `${user.name} has been completely unblocked.`) }
    ]);
  };

  const adminFiltered = profiles.filter((p: any) => 
    p.name.toLowerCase().includes(adminSearch.toLowerCase()) || 
    p.id.toString().toLowerCase().includes(adminSearch.toLowerCase())
  );

  const totalUsers = profiles.length;
  const bannedUsers = profiles.filter((p: any) => p.isBanned).length;

  return (
    <View className="flex-1 bg-gray-50">
      <View className="p-5 bg-white border-b border-gray-200 shadow-sm elevation-2 z-10">
        <Text className="text-[28px] font-black tracking-tight text-gray-900 mb-1">
          DateRoot <Text className="text-green-500">ADMIN</Text>
        </Text>
        <Text className="text-[12px] font-bold text-gray-400 mb-4">Mobile Command Center</Text>
        
        {viewMode === 'users' && (
          <View className="flex-row items-center bg-gray-100 rounded-xl px-4 h-[45px] border border-gray-200">
            <Text className="text-[16px] mr-2">🔍</Text>
            <TextInput 
              className="flex-1 text-black font-semibold"
              placeholder="Search user ID or Name..." 
              placeholderTextColor="#999"
              value={adminSearch}
              onChangeText={setAdminSearch}
              autoCorrect={false}
            />
          </View>
        )}
      </View>

      <ScrollView className="flex-1" contentContainerStyle={{ paddingBottom: 40 }}>
        <View className="flex-row p-4 justify-between">
          <View className="flex-1 bg-white p-4 rounded-2xl mr-2 border border-gray-200 shadow-sm elevation-1 items-center">
            <Text className="text-[24px] font-black text-gray-900">{totalUsers}</Text>
            <Text className="text-[10px] font-bold text-gray-400 uppercase mt-1">Total Users</Text>
          </View>
          <View className="flex-1 bg-white p-4 rounded-2xl mx-1 border border-gray-200 shadow-sm elevation-1 items-center border-b-4 border-b-red-500">
            <Text className="text-[24px] font-black text-gray-900">{bannedUsers}</Text>
            <Text className="text-[10px] font-bold text-gray-400 uppercase mt-1">Banned</Text>
          </View>
          <View className="flex-1 bg-white p-4 rounded-2xl ml-2 border border-gray-200 shadow-sm elevation-1 items-center border-b-4 border-b-green-500">
            <Text className="text-[24px] font-black text-green-500">{isVip ? 'LIVE' : 'OFF'}</Text>
            <Text className="text-[10px] font-bold text-gray-400 uppercase mt-1">Server</Text>
          </View>
        </View>

        {/* 🚀 THE TOGGLE TABS */}
        <View className="flex-row mx-5 mt-2 mb-4 border-b border-gray-200">
          <TouchableOpacity onPress={() => setViewMode('users')} className={`flex-1 pb-3 items-center ${viewMode === 'users' ? 'border-b-2 border-green-500' : ''}`}>
            <Text className={`font-black tracking-wider uppercase ${viewMode === 'users' ? 'text-green-500' : 'text-gray-400'}`}>User Database</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => setViewMode('reports')} className={`flex-1 pb-3 items-center ${viewMode === 'reports' ? 'border-b-2 border-red-500' : ''}`}>
            <Text className={`font-black tracking-wider uppercase ${viewMode === 'reports' ? 'text-red-500' : 'text-gray-400'}`}>
              🚨 Pending Reports
            </Text>
          </TouchableOpacity>
        </View>

        <View className="bg-white border-y border-gray-200">
          
          {/* USER DATABASE VIEW */}
          {viewMode === 'users' && (
            <View className="p-4">
              {/* 🔴 GLOBAL NUKE CONTROLS */}
              <View className="bg-red-50 p-4 rounded-2xl border border-red-200 mb-6">
                <Text className="text-red-800 font-bold mb-3 text-[14px]">GLOBAL DATABASE WIPES</Text>
                <View className="flex-row justify-between">
                  <TouchableOpacity 
                    onPress={handleWipeLobby}
                    className="bg-red-500 py-3 px-2 rounded-xl flex-1 mr-2 items-center shadow-sm"
                  >
                    <Text className="text-white font-black text-[12px]">WIPE LOBBY</Text>
                  </TouchableOpacity>
                  <TouchableOpacity 
                    onPress={handleWipePrivateChats}
                    className="bg-red-700 py-3 px-2 rounded-xl flex-1 ml-2 items-center shadow-sm"
                  >
                    <Text className="text-white font-black text-[12px]">WIPE ALL DMs</Text>
                  </TouchableOpacity>
                </View>
              </View>

              {adminFiltered.map((u: any, index: number) => (
                <View key={u.id} className={`flex-row py-4 items-center ${index !== adminFiltered.length - 1 ? 'border-b border-gray-100' : ''}`}>
                  <Image source={{uri: u.image}} className="w-[50px] h-[50px] rounded-full mr-4 bg-gray-200" />
                  <View className="flex-1">
                    <Text className={`font-black text-[16px] ${u.isBanned ? 'text-red-500 line-through' : 'text-gray-900'}`}>{u.name}, {u.age}</Text>
                    <Text className="text-[12px] font-semibold text-gray-500 mt-0.5">{u.town} • {u.gender}</Text>
                    <Text className="text-[10px] font-mono text-gray-400 mt-1">ID: {u.id}</Text>
                  </View>
                  
                  {u.isBanned ? (
                    <View className="flex-col">
                      <TouchableOpacity 
                        onPress={() => handleUnbanUser(u)} 
                        className="bg-green-500 py-1.5 px-3 rounded-md shadow-sm elevation-1 mb-1 items-center"
                      >
                        <Text className="text-white text-[10px] font-black tracking-wider">UNBAN</Text>
                      </TouchableOpacity>
                      <TouchableOpacity 
                        onPress={() => handleUnblockIpUser(u)} 
                        className="bg-green-700 py-1.5 px-3 rounded-md shadow-sm elevation-1 items-center"
                      >
                        <Text className="text-white text-[10px] font-black tracking-wider">UNBLOCK IP</Text>
                      </TouchableOpacity>
                    </View>
                  ) : (
                    <View className="flex-col">
                      <TouchableOpacity 
                        onPress={() => handleBanUser(u)} 
                        className="bg-orange-500 py-1.5 px-3 rounded-md shadow-sm elevation-1 mb-1 items-center"
                      >
                        <Text className="text-white text-[10px] font-black tracking-wider">BAN</Text>
                      </TouchableOpacity>
                      <TouchableOpacity 
                        onPress={() => handleIpBlockUser(u)} 
                        className="bg-gray-900 py-1.5 px-3 rounded-md shadow-sm elevation-1 items-center"
                      >
                        <Text className="text-white text-[10px] font-black tracking-wider">IP BLOCK</Text>
                      </TouchableOpacity>
                    </View>
                  )}
                </View>
              ))}
            </View>
          )}

          {/* 🚀 REPORTS VIEW */}
          {viewMode === 'reports' && reports.length === 0 && (
            <Text className="text-center text-gray-400 font-bold py-10">No pending reports. The app is safe!</Text>
          )}

          {viewMode === 'reports' && reports.map((report: any, index: number) => {
            const reportedUser = profiles.find((p: any) => p.id === report.reported_id);
            if (!reportedUser) return null;

            return (
              <View key={report.id} className={`p-4 ${index !== reports.length - 1 ? 'border-b border-gray-100' : ''}`}>
                <View className="flex-row items-center mb-3">
                  <Image source={{uri: reportedUser.image}} className="w-[40px] h-[40px] rounded-full mr-3 border border-gray-200" />
                  <View className="flex-1">
                    <Text className="font-black text-gray-900 text-[16px]">{reportedUser.name} <Text className="text-red-500 font-normal text-sm">was reported</Text></Text>
                    <Text className="text-xs text-gray-400 font-mono mt-0.5">ID: {reportedUser.id}</Text>
                  </View>
                </View>

                <View className="bg-red-50 p-3 rounded-lg border border-red-100 mb-3">
                  <Text className="text-red-800 font-bold uppercase text-[10px] tracking-wider mb-1">Reason for report:</Text>
                  <Text className="text-red-600 font-bold text-sm">{report.reason || "No reason provided"}</Text>
                </View>

                <View className="flex-row justify-end space-x-2">
                  <TouchableOpacity onPress={() => handleResolveReport(report.id)} className="bg-gray-200 py-2 px-4 rounded-lg mr-2">
                    <Text className="text-gray-700 font-bold text-xs">Dismiss Report</Text>
                  </TouchableOpacity>
                  <TouchableOpacity 
                    onPress={() => {
                      executeAdminAction('ban_user', reportedUser.id, `${reportedUser.name} has been banned.`);
                      handleResolveReport(report.id);
                    }} 
                    className="bg-red-600 py-2 px-4 rounded-lg shadow-sm"
                  >
                    <Text className="text-white font-bold text-xs">Ban User & Resolve</Text>
                  </TouchableOpacity>
                </View>
              </View>
            )
          })}
        </View>
      </ScrollView>
    </View>
  );
};