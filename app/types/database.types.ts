export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      bars: {
        Row: {
          content: string
          created_at: string
          id: string
          lang: Database["public"]["Enums"]["bar_lang"] | null
          p: number
          q: number
          repetitions: number | null
          section_id: string
          sort_key: number | null
          type: Database["public"]["Enums"]["bar_type"]
        }
        Insert: {
          content: string
          created_at?: string
          id?: string
          lang?: Database["public"]["Enums"]["bar_lang"] | null
          p: number
          q: number
          repetitions?: number | null
          section_id: string
          sort_key?: number | null
          type: Database["public"]["Enums"]["bar_type"]
        }
        Update: {
          content?: string
          created_at?: string
          id?: string
          lang?: Database["public"]["Enums"]["bar_lang"] | null
          p?: number
          q?: number
          repetitions?: number | null
          section_id?: string
          sort_key?: number | null
          type?: Database["public"]["Enums"]["bar_type"]
        }
        Relationships: [
          {
            foreignKeyName: "bars_section_id_fkey"
            columns: ["section_id"]
            isOneToOne: false
            referencedRelation: "sections"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          created_at: string
          display_name: string
          id: string
          username: string
        }
        Insert: {
          created_at?: string
          display_name: string
          id: string
          username: string
        }
        Update: {
          created_at?: string
          display_name?: string
          id?: string
          username?: string
        }
        Relationships: []
      }
      rate_limit_events: {
        Row: {
          action: string
          created_at: string
          id: number
          user_id: string
        }
        Insert: {
          action: string
          created_at?: string
          id?: number
          user_id: string
        }
        Update: {
          action?: string
          created_at?: string
          id?: number
          user_id?: string
        }
        Relationships: []
      }
      record_tracks: {
        Row: {
          id: string
          p: number
          q: number
          record_id: string
          sort_key: number | null
          track_id: string
        }
        Insert: {
          id?: string
          p: number
          q: number
          record_id: string
          sort_key?: number | null
          track_id: string
        }
        Update: {
          id?: string
          p?: number
          q?: number
          record_id?: string
          sort_key?: number | null
          track_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "record_tracks_record_id_fkey"
            columns: ["record_id"]
            isOneToOne: false
            referencedRelation: "records"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "record_tracks_track_id_fkey"
            columns: ["track_id"]
            isOneToOne: false
            referencedRelation: "tracks"
            referencedColumns: ["id"]
          },
        ]
      }
      records: {
        Row: {
          created_at: string
          id: string
          name: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          name: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          name?: string
          user_id?: string
        }
        Relationships: []
      }
      sections: {
        Row: {
          created_at: string
          id: string
          is_starred: boolean
          name: string
          p: number
          q: number
          repetitions: number
          sort_key: number | null
          track_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_starred?: boolean
          name: string
          p: number
          q: number
          repetitions?: number
          sort_key?: number | null
          track_id: string
        }
        Update: {
          created_at?: string
          id?: string
          is_starred?: boolean
          name?: string
          p?: number
          q?: number
          repetitions?: number
          sort_key?: number | null
          track_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "sections_track_id_fkey"
            columns: ["track_id"]
            isOneToOne: false
            referencedRelation: "tracks"
            referencedColumns: ["id"]
          },
        ]
      }
      tracks: {
        Row: {
          created_at: string
          id: string
          last_played_at: string | null
          name: string
          note: string | null
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          last_played_at?: string | null
          name: string
          note?: string | null
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          last_played_at?: string | null
          name?: string
          note?: string | null
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      append_tracks_to_record: {
        Args: { p_record_id: string; p_track_ids: string[] }
        Returns: {
          id: string
          p: number
          q: number
          record_id: string
          sort_key: number | null
          track_id: string
        }[]
        SetofOptions: {
          from: "*"
          to: "record_tracks"
          isOneToOne: false
          isSetofReturn: true
        }
      }
      bar_bounds: {
        Args: {
          p_is_before: boolean
          p_reference_bar_id: string
          p_section_id: string
        }
        Returns: Record<string, unknown>
      }
      create_bar: {
        Args: {
          p_content: string
          p_is_before?: boolean
          p_lang: Database["public"]["Enums"]["bar_lang"]
          p_reference_bar_id?: string
          p_repetitions: number
          p_section_id: string
          p_type: Database["public"]["Enums"]["bar_type"]
        }
        Returns: {
          content: string
          created_at: string
          id: string
          lang: Database["public"]["Enums"]["bar_lang"] | null
          p: number
          q: number
          repetitions: number | null
          section_id: string
          sort_key: number | null
          type: Database["public"]["Enums"]["bar_type"]
        }
        SetofOptions: {
          from: "*"
          to: "bars"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      create_section: {
        Args: {
          p_is_before?: boolean
          p_name: string
          p_reference_section_id?: string
          p_repetitions: number
          p_track_id: string
        }
        Returns: {
          created_at: string
          id: string
          is_starred: boolean
          name: string
          p: number
          q: number
          repetitions: number
          sort_key: number | null
          track_id: string
        }
        SetofOptions: {
          from: "*"
          to: "sections"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      duplicate_bar: {
        Args: { p_bar_id: string }
        Returns: {
          content: string
          created_at: string
          id: string
          lang: Database["public"]["Enums"]["bar_lang"] | null
          p: number
          q: number
          repetitions: number | null
          section_id: string
          sort_key: number | null
          type: Database["public"]["Enums"]["bar_type"]
        }
        SetofOptions: {
          from: "*"
          to: "bars"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      duplicate_section: {
        Args: { p_section_id: string }
        Returns: {
          created_at: string
          id: string
          is_starred: boolean
          name: string
          p: number
          q: number
          repetitions: number
          sort_key: number | null
          track_id: string
        }
        SetofOptions: {
          from: "*"
          to: "sections"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      duplicate_track: {
        Args: { source_track_id: string }
        Returns: {
          created_at: string
          id: string
          last_played_at: string | null
          name: string
          note: string | null
          user_id: string
        }
        SetofOptions: {
          from: "*"
          to: "tracks"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      find_intermediate: {
        Args: { p1: number; p2: number; q1: number; q2: number }
        Returns: Record<string, unknown>
      }
      import_sections: {
        Args: {
          p_only_starred?: boolean
          p_source_track_id: string
          p_target_track_id: string
        }
        Returns: {
          created_at: string
          id: string
          is_starred: boolean
          name: string
          p: number
          q: number
          repetitions: number
          sort_key: number | null
          track_id: string
        }[]
        SetofOptions: {
          from: "*"
          to: "sections"
          isOneToOne: false
          isSetofReturn: true
        }
      }
      mark_track_played: { Args: { p_track_id: string }; Returns: undefined }
      move_bar: {
        Args: {
          p_bar_id: string
          p_is_before?: boolean
          p_reference_bar_id?: string
          p_target_section_id?: string
        }
        Returns: {
          content: string
          created_at: string
          id: string
          lang: Database["public"]["Enums"]["bar_lang"] | null
          p: number
          q: number
          repetitions: number | null
          section_id: string
          sort_key: number | null
          type: Database["public"]["Enums"]["bar_type"]
        }
        SetofOptions: {
          from: "*"
          to: "bars"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      move_section: {
        Args: {
          p_is_before?: boolean
          p_reference_section_id?: string
          p_section_id: string
        }
        Returns: {
          created_at: string
          id: string
          is_starred: boolean
          name: string
          p: number
          q: number
          repetitions: number
          sort_key: number | null
          track_id: string
        }
        SetofOptions: {
          from: "*"
          to: "sections"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      place_record_track: {
        Args: {
          p_is_before?: boolean
          p_record_id: string
          p_reference_track_id?: string
          p_track_id: string
        }
        Returns: {
          id: string
          p: number
          q: number
          record_id: string
          sort_key: number | null
          track_id: string
        }
        SetofOptions: {
          from: "*"
          to: "record_tracks"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      renormalize_bars: { Args: { p_section_id: string }; Returns: undefined }
      renormalize_record_tracks: {
        Args: { p_record_id: string }
        Returns: undefined
      }
      renormalize_sections: { Args: { p_track_id: string }; Returns: undefined }
      section_bounds: {
        Args: {
          p_is_before: boolean
          p_reference_section_id: string
          p_track_id: string
        }
        Returns: Record<string, unknown>
      }
    }
    Enums: {
      bar_lang: "en-US" | "zh-TW"
      bar_type: "spelling" | "word" | "interval"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {
      bar_lang: ["en-US", "zh-TW"],
      bar_type: ["spelling", "word", "interval"],
    },
  },
} as const
