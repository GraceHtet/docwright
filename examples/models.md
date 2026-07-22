<!-- DOCWRIGHT:AUTO:Post -->
## Post
**Table:** posts

### Associations
- belongs_to :user

### Validations
- ActiveRecord::Validations::PresenceValidator on : user
- ActiveRecord::Validations::PresenceValidator on : title
- ActiveRecord::Validations::LengthValidator on : title
- ActiveRecord::Validations::PresenceValidator on : body
- ActiveRecord::Validations::LengthValidator on : body
<!-- DOCWRIGHT:END:Post -->

### Notes for Post

<!-- Add your notes about Post here -->

My note for post is here . They are blog post created by user

<!-- DOCWRIGHT:AUTO:User -->
## User
**Table:** users

### Associations
- has_many :posts

### Validations
- ActiveRecord::Validations::PresenceValidator on : name
- ActiveRecord::Validations::LengthValidator on : name
<!-- DOCWRIGHT:END:User -->

### Notes for User

<!-- Add your notes about User here -->

User is app user who can also create blog post.
