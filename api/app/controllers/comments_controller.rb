class CommentsController < ApplicationController

  def index
    @comments = Comment.where(is_active: true).order(created_at: :desc)
    render json: @comments
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      ActionCable.server.broadcast("comments_channel", @comment)
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.update(is_active: false)
      ActionCable.server.broadcast("comments_channel", { deleted: true, id: @comment.id })
    render json:{ message: "Comment deactivated successfully" }, status: :ok
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:author, :content)
  end
end
