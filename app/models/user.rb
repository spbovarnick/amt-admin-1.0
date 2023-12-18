class User < ApplicationRecord
  # pwd validation to allow blank password field on update
  validates :password, presence: true, confirmation: true, on: :create
  validates :password, confirmation: true, allow_blank: true, on: :update

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # add back :registerable to enable sign ups
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :registerable
end
