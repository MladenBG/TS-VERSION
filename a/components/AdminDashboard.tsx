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

export const AdminDashboard = ({ profiles, setProfiles, isVip }: any) => {
  const [adminSearch, setAdminSearch] = useState('');
  const [viewMode, setViewMode] = useState<'users' | 'reports'>('users');
  const [reports, setReports] = useState<any[]>([]);

  // 🚀 FETCH LIVE REPORTS FROM DATABASE
  const fetchReports = async () => {
    try {
      // 🚨 UPDATED TO USE API_URL
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
      // 🚨 UPDATED TO USE API_URL
      await fetch(`${API_URL}/api/admin/resolve-report`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reportId })
      });
      // Remove it from the screen immediately
      setReports(prev => prev.filter(r => r.id !== reportId));
      Alert.alert("Resolved", "Report has been cleared.");
    } catch (e) {
      Alert.alert("Error", "Could not resolve report.");
    }
  };

  const adminFiltered = profiles.filter((p: any) => 
    p.name.toLowerCase().includes(adminSearch.toLowerCase()) || 
    p.id.toLowerCase().includes(adminSearch.toLowerCase())
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

        {/* 🚀 THE NEW TOGGLE TABS */}
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
          {viewMode === 'users' && adminFiltered.map((u: any, index: number) => (
            <View key={u.id} className={`flex-row p-4 items-center ${index !== adminFiltered.length - 1 ? 'border-b border-gray-100' : ''}`}>
              <Image source={{uri: u.image}} className="w-[50px] h-[50px] rounded-full mr-4 bg-gray-200" />
              <View className="flex-1">
                <Text className={`font-black text-[16px] ${u.isBanned ? 'text-red-500 line-through' : 'text-gray-900'}`}>{u.name}, {u.age}</Text>
                <Text className="text-[12px] font-semibold text-gray-500 mt-0.5">{u.town} • {u.gender}</Text>
                <Text className="text-[10px] font-mono text-gray-400 mt-1">ID: {u.id}</Text>
              </View>
              <TouchableOpacity onPress={() => setProfiles((prev: any) => prev.map((p: any) => p.id === u.id ? {...p, isBanned: !p.isBanned} : p))} className={`py-2 px-5 rounded-full shadow-sm elevation-1 ${u.isBanned ? 'bg-green-500' : 'bg-red-500'}`}>
                <Text className="text-white text-[12px] font-black tracking-wider">{u.isBanned ? 'UNBAN' : 'BAN'}</Text>
              </TouchableOpacity>
            </View>
          ))}

          {/* 🚀 REPORTS VIEW */}
          {viewMode === 'reports' && reports.length === 0 && (
            <Text className="text-center text-gray-400 font-bold py-10">No pending reports. The app is safe!</Text>
          )}

          {viewMode === 'reports' && reports.map((report: any, index: number) => {
            // Find the full user data based on the reported ID
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
                      setProfiles((prev: any) => prev.map((p: any) => p.id === reportedUser.id ? {...p, isBanned: true} : p));
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