/**
 * Custom hook for loading expense categories from the backend
 */

import { useCallback, useEffect, useState } from "react";
import { fetchCategories } from "../services/api";
import { EXPENSE_CATEGORIES } from "../constants/categories";

export function useCategories() {
  const [categories, setCategories] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  const loadCategories = useCallback(async () => {
    try {
      setLoading(true);
      const data = await fetchCategories();
      setCategories(data.map((category) => category.name));
    } catch (error) {
      console.error("Error fetching categories:", error);
      // Fall back to the built-in list so the form stays usable if the API is down
      setCategories([...EXPENSE_CATEGORIES]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadCategories();
  }, [loadCategories]);

  return { categories, loading, refetch: loadCategories };
}
