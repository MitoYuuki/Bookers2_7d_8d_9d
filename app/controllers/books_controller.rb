class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
  end

  def index
    @books = Book.all
    @book = Book.new

    @book = Post.find(params[:id])
    @tags = @book.tag_counts_on(:tags)

    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    
    # 並び替え条件に応じて異なる並び替えを実行
    @books = case params[:sort]
             when "rating"
               Book.order(score: :desc)
             when "new"
               Book.order(created_at: :desc)
             else
               # お気に入り順（デフォルト）
               Book.includes(:week_favorites).sort_by { |book| -book.week_favorites.count }
             end
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path
  end

  def tag
    @tag = params[:tag]
    @books = Book.tagged_with(@tag)
  end

  private

  def book_params
    params.require(:book).permit(:title, :body, :score, :tag_list)
  end

  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end
end
