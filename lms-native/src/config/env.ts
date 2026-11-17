export const ENV = {
  API_BASE_URL: process.env.EXPO_PUBLIC_API_BASE_URL || 'https://lms-dev-api.duckdns.org/api',
  KEYCLOAK_BASE_URL: process.env.EXPO_PUBLIC_KEYCLOAK_BASE_URL || 'https://auth-dev-api.duckdns.org',
  KEYCLOAK_REALM: 'lms',
  KEYCLOAK_CLIENT_ID: 'lms-mobile',
  REDIRECT_URI: 'vn.vnic.lms://oauth/callback',
  USE_MOCK_DATA: false,
  SCHOOL_NAME: 'ĐẠI HỌC CÔNG THƯƠNG TP.HCM',
  SCHOOL_CODE: 'HUIT',
};

