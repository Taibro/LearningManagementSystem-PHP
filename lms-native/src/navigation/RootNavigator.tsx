import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { FloatingBottomNav, TabKey } from '../components/common/FloatingBottomNav';
import { useAuth } from '../hooks/useAuth';

// Screens
import { LoginScreen } from '../screens/auth/LoginScreen';
import {
  HomeScreen,
  ScheduleScreen,
  AttendanceScreen,
  ProfileScreen,
  AcademicResultScreen,
  CurriculumScreen,
  ReceiptScreen,
  TransactionHistoryScreen,
  StudentInfoScreen,
  ConductScreen,
  NewsScreen,
  SurveyScreen,
  ChatbotScreen,
  ChangePasswordScreen,
  AllFeaturesScreen,
  AttendanceStatsScreen,
  AchievementScreen,
} from '../screens/student';

export type RootStackParamList = {
  Login: undefined;
  MainTabs: { screen?: string } | undefined;
  grades: undefined;
  curriculum: undefined;
  receipt: undefined;
  transactions: undefined;
  student_info: undefined;
  conduct: undefined;
  news: undefined;
  survey: undefined;
  chatbot: undefined;
  change_password: undefined;
  all_features: undefined;
  attendance_stats: undefined;
  achievement: undefined;
};

export type MainTabParamList = {
  tab_home: undefined;
  tab_schedule: undefined;
  tab_attendance: undefined;
  tab_profile: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<MainTabParamList>();

const MainTabs: React.FC<{ navigation: any }> = ({ navigation }) => {
  const { logout } = useAuth();

  return (
    <Tab.Navigator
      screenOptions={{ headerShown: false }}
      tabBar={({ state, navigation: tabNav }) => {
        const routeName = state.routes[state.index].name;
        const activeTab: TabKey =
          routeName === 'tab_schedule'
            ? 'schedule'
            : routeName === 'tab_attendance'
            ? 'attendance'
            : routeName === 'tab_profile'
            ? 'profile'
            : 'home';

        return (
          <FloatingBottomNav
            activeTab={activeTab}
            onTabChange={(tab) => {
              const target =
                tab === 'schedule'
                  ? 'tab_schedule'
                  : tab === 'attendance'
                  ? 'tab_attendance'
                  : tab === 'profile'
                  ? 'tab_profile'
                  : 'tab_home';
              const targetRoute = state.routes.find((r) => r.name === target);
              if (targetRoute) {
                const event = tabNav.emit({
                  type: 'tabPress',
                  target: targetRoute.key,
                  canPreventDefault: true,
                });
                if (!event.defaultPrevented) {
                  tabNav.navigate(target);
                }
              }
            }}
          />
        );
      }}
    >
      <Tab.Screen name="tab_home">
        {() => (
          <HomeScreen
            onNavigate={(screen) => {
              if (['schedule', 'attendance', 'profile'].includes(screen)) {
                navigation.navigate('MainTabs', { screen: `tab_${screen}` });
              } else if (screen === 'tuition') {
                navigation.navigate('receipt');
              } else {
                navigation.navigate(screen);
              }
            }}
          />
        )}
      </Tab.Screen>
      <Tab.Screen name="tab_schedule">
        {() => (
          <ScheduleScreen
            onBack={() => navigation.navigate('MainTabs', { screen: 'tab_home' })}
          />
        )}
      </Tab.Screen>
      <Tab.Screen name="tab_attendance">
        {() => (
          <AttendanceScreen
            onBack={() => navigation.navigate('MainTabs', { screen: 'tab_home' })}
            onGoToStats={() => navigation.navigate('attendance_stats')}
          />
        )}
      </Tab.Screen>
      <Tab.Screen name="tab_profile">
        {() => (
          <ProfileScreen
            onNavigate={(screen) => {
              if (['schedule', 'attendance', 'profile'].includes(screen)) {
                navigation.navigate('MainTabs', { screen: `tab_${screen}` });
              } else if (screen === 'tuition') {
                navigation.navigate('receipt');
              } else {
                navigation.navigate(screen);
              }
            }}
            onLogout={logout}
          />
        )}
      </Tab.Screen>
    </Tab.Navigator>
  );
};

export const RootNavigator: React.FC = () => {
  const { isAuthenticated } = useAuth();

  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          animation: 'slide_from_right',
        }}
      >
        {!isAuthenticated ? (
          <Stack.Screen name="Login" component={LoginScreen} />
        ) : (
          <>
            <Stack.Screen name="MainTabs" component={MainTabs} />
            <Stack.Screen name="grades">
              {({ navigation }) => <AcademicResultScreen onBack={() => navigation.goBack()} />}
            </Stack.Screen>
            <Stack.Screen name="curriculum">
              {({ navigation }) => <CurriculumScreen onBack={() => navigation.goBack()} />}
            </Stack.Screen>
            <Stack.Screen name="receipt">
              {({ navigation }) => (
                <ReceiptScreen
                  onBack={() => navigation.goBack()}
                  onGoToTransactions={() => navigation.navigate('transactions')}
                />
              )}
            </Stack.Screen>
            <Stack.Screen name="transactions">
              {({ navigation }) => (
                <TransactionHistoryScreen onBack={() => navigation.goBack()} />
              )}
            </Stack.Screen>
            <Stack.Screen name="student_info">
              {({ navigation }) => <StudentInfoScreen onBack={() => navigation.goBack()} />}
            </Stack.Screen>
            <Stack.Screen name="conduct">
              {({ navigation }) => <ConductScreen onBack={() => navigation.goBack()} />}
            </Stack.Screen>
            <Stack.Screen name="news">
              {({ navigation }) => <NewsScreen onBack={() => navigation.goBack()} />}
            </Stack.Screen>
            <Stack.Screen name="survey">
              {({ navigation }) => <SurveyScreen onBack={() => navigation.goBack()} />}
            </Stack.Screen>
            <Stack.Screen name="chatbot">
              {({ navigation }) => <ChatbotScreen onBack={() => navigation.goBack()} />}
            </Stack.Screen>
            <Stack.Screen name="change_password">
              {({ navigation }) => <ChangePasswordScreen onBack={() => navigation.goBack()} />}
            </Stack.Screen>
            <Stack.Screen name="all_features">
              {({ navigation }) => (
                <AllFeaturesScreen
                  onBack={() => navigation.goBack()}
                  onNavigate={(screen) => {
                    if (['schedule', 'attendance', 'profile'].includes(screen)) {
                      navigation.navigate('MainTabs', { screen: `tab_${screen}` });
                    } else if (screen === 'tuition') {
                      navigation.navigate('receipt');
                    } else {
                      navigation.navigate(screen);
                    }
                  }}
                />
              )}
            </Stack.Screen>
            <Stack.Screen name="attendance_stats">
              {({ navigation }) => <AttendanceStatsScreen onBack={() => navigation.goBack()} />}
            </Stack.Screen>
            <Stack.Screen name="achievement">
              {({ navigation }) => <AchievementScreen onBack={() => navigation.goBack()} />}
            </Stack.Screen>
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};
