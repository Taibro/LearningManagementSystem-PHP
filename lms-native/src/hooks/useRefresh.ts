import { useState, useCallback } from 'react';

/**
 * Custom hook quản lý trạng thái pull-to-refresh
 */
export const useRefresh = (onRefreshCallback: () => Promise<void> | void, timeoutMs = 8000) => {
  const [refreshing, setRefreshing] = useState(false);

  const handleRefresh = useCallback(async () => {
    setRefreshing(true);
    const timeout = setTimeout(() => {
      setRefreshing(false);
    }, timeoutMs);

    try {
      await onRefreshCallback();
    } catch (err) {
      console.warn('[useRefresh] Refresh callback error:', err);
    } finally {
      clearTimeout(timeout);
      setRefreshing(false);
    }
  }, [onRefreshCallback, timeoutMs]);

  return { refreshing, onRefresh: handleRefresh };
};

