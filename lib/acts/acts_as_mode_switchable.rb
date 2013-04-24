# encoding: utf-8
module Acts
  module ModeSwitchable

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        before_create :set_record_mode
      end
    end

    module InstanceMethods
      def set_record_mode
        self.record_mode = CURRENT_RUN_MODE
      end
    end

    module ClassMethods
      # 設定された起動時のの記録種別によってレコードを切り替える動作を、モデルに付与します。
      # 
      # 付与するモデルのテーブルに、recode_modeカラムを追加してください。
      #   add_column :switched_model_table, :record_mode, :integer, :null => false, :default => 0
      #   # 型、default値はサンプル
      #   # 依存モデルのRUN_MODEハッシュ定数のvalueと型を一致させ、default値は考慮の上決定のこと
      # 
      # 付与するモデルに、acts_as_mode_switchableメソッドを実行してください。
      # 
      # mode_inスコープが登録されます。通常のスコープと同じように使用してください。
      # ==== Args
      # ==== Return
      # ==== Raise
      def acts_as_mode_switchable
        self.scope :mode_in, ->(mode = CURRENT_RUN_MODE) {
          where(record_mode:
                case mode
                when Symbol
                  depended_class::RUN_MODE[mode] || raise(ArgumentError, "不正な引数です")
                else
                  raise(ArgumentError, "不正な引数です") unless RUN_MODE.values.include?(mode)
                  mode
                end
                )
        }
      end

    end

  end
end
ActiveRecord::Base.send(:include, Acts::ModeSwitchable)
