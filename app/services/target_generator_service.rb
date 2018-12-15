class TargetGeneratorService
  attr_reader :result, :template
  delegate :success?, :failure?, to: :result

  def initialize(user, template)
    @user = user
    @template = template
  end

  def call
    @target = @user.targets.create!(code: find_code, name: @template.name,
                                    kind: @template.kind, template: @template)

    @result = ServiceResult.new(:success) #2017-05-18 Add to all services?
  end

  def find_code
    PromotionCodeService.generate(8)
  end
end
