Localpersonfinder::Application.routes.draw do
  root  :to => "people#index"
  match "people/index"                      => "people#index",              :via => :get
  match "people/seek"                       => "people#seek",               :via => :get
  match "people/seek"                       => "people#seek",               :via => :post
  match "person"                            => "people#new",                :via => :get
  match "person"                            => "people#create",             :via => :post
  match "people/view/:id"                   => "people#view",               :via => :get, :as => "people_view"
  match "people/update/:id"                 => "people#update",             :via => :post
  match "people/create"                     => "people#create",             :via => :get
  match "people/provide"                    => "people#provide",            :via => :get
  match "people/provide"                    => "people#provide",            :via => :post
  match "person/extend_days"                => "people#extend_days",        :via => :get
  match "person/subscribe_email"            => "people#subscribe_email",    :via => :get
  match "person/delete"                     => "people#delete",             :via => :get
  match "person/restore"                    => "people#restore",            :via => :get
  match "person/restore"                    => "people#restore",            :via => :post
  match "person/note_invalid_apply"         => "people#note_invalid_apply", :via => :get
  match "person/note_invalid"               => "people#note_invalid",       :via => :get
  match "person/note_valid_apply"           => "people#note_valid_apply",   :via => :get
  match "person/spam/:id/:note_id"          => "people#spam",               :via => :get
  match "person/spam/:id/:note_id"          => "people#spam",               :via => :post
  match "person/spam_cancel/:id/:note_id"   => "people#spam_cancel",        :via => :get
  match "person/spam_cancel/:id/:note_id"   => "people#spam_cancel",        :via => :post
  match "person/personal_info"              => "people#personal_info",      :via => :get
  match "person/personal_info"              => "people#personal_info",      :via => :post
  match "person/personal_info/:id/:note_id" => "people#personal_info",      :via => :get
  match "person/personal_info/:id/:note_id" => "people#personal_info",      :via => :post
  match "person/complete"                   => "people#complete",           :via => :post
  match "people/multiviews"                 => "people#multiviews",         :via => :post
  match "people/dup_merge"                  => "people#dup_merge",          :via => :post
  match "people"                            => "active_resource#people",    :via => :get
  match "note"                              => "active_resource#note",      :via => :get
  match "people/:id"                        => "active_resource#people_update", :via => :put
  match "notes/:id"                         => "active_resource#note_update",   :via => :put

end
