class XPostsController < ApplicationController
  before_action :require_user_logged_in!
  before_action :set_x_post, only: [:show, :edit, :update, :destroy, :publish]
  
  def index
    @x_posts = Current.user.x_posts.order(created_at: :desc)
  end

  def show
    @x_post = Current.user.x_posts.find(params[:id])
  end

  def edit
    @x_post = Current.user.x_posts.find(params[:id])
  end

  def update
    @x_post = Current.user.x_posts.find(params[:id])
    if @x_post.update(x_post_params)
      redirect_to @x_post, notice: "X post başarıyla güncellendi."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @x_post = Current.user.x_posts.find(params[:id])
    @x_post.destroy
    redirect_to x_posts_path, notice: "X post başarıyla silindi."
    end

    def new
        @x_post = XPost.new
    end

    def create
        @x_post = Current.user.x_posts.build(x_post_params)
        if @x_post.save
            redirect_to @x_post, notice: "X post başarıyla oluşturuldu."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def publish
      unless @x_post.user_id == Current.user.id
        redirect_to x_posts_path, alert: "Bu post size ait değil." and return
      end

      if @x_post.published?
        redirect_to @x_post, notice: "Post zaten yayınlanmış." and return
      end

      if @x_post.publish_at.present? && @x_post.publish_at > Time.current
        # Zamanı gelmemişse job'ı yeniden planla
        XPostJob.set(wait_until: @x_post.publish_at).perform_later(@x_post)
        redirect_to @x_post, notice: "Post zamanı gelince yayınlanacak." and return
      end

      begin
        @x_post.publish_to_x!
        redirect_to @x_post, notice: "Post X'te paylaşıldı."
      rescue => e
        redirect_to @x_post, alert: "Paylaşım hatası: #{e.message}"
      end
    end

  private

  def x_post_params
    params.require(:x_post).permit(:content, :scheduled_at, :body, :publish_at, :x_post_id, :x_account_id)
  end

  def set_x_post
    @x_post = Current.user.x_posts.find(params[:id])
  end
end