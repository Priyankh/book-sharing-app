class Book < ActiveRecord::Base

  validates :title, :description, :author, presence: true
  validates :isbn, :isbn_format => true
  validates :edition, numericality: {only_integer: true}, :allow_nil => true

  has_and_belongs_to_many :users, join_table: :books_owners

  def self.filter_by filter, title
    Book.where(filter + " LIKE ?", "%" + title.to_s + "%")
  end

  def save_or_update_with_user
    if block_given?
      current_user = yield()
    end

    if valid?
      existing_book = Book.find_by(isbn: isbn)

      if existing_book
        existing_book.users << User.find_or_create_by(name: current_user)
      else
        save
        users << User.find_or_create_by(name: current_user)
      end
    end
  end

end

