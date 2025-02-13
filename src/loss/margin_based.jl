# ==========================================================================
# L(y, t) = max(0, -yt)

immutable PerceptronLoss <: MarginBasedLoss end

value{T<:Number}(l::PerceptronLoss, yt::T) = max(zero(T), -yt)
deriv{T<:Number}(l::PerceptronLoss, yt::T) = yt >= 0 ? zero(T) : -one(T)
deriv2{T<:Number}(l::PerceptronLoss, yt::T) = zero(T)
value_deriv{T<:Number}(l::PerceptronLoss, yt::T) = yt >= 0 ? (zero(T), zero(T)) : (-yt, -one(T))

isdifferentiable(::PerceptronLoss) = false
isdifferentiable(::PerceptronLoss, at) = at != 0
istwicedifferentiable(::PerceptronLoss) = false
istwicedifferentiable(::PerceptronLoss, at) = at != 0
islipschitzcont(::PerceptronLoss) = true
islipschitzcont_deriv(::PerceptronLoss) = true
isconvex(::PerceptronLoss) = true
isstronglyconvex(::PerceptronLoss) = false
isclipable(::PerceptronLoss) = true

# ==========================================================================
# L(y, t) = ln(1 + exp(-yt))

immutable LogitMarginLoss <: MarginBasedLoss end

value(l::LogitMarginLoss, yt::Number) = log1p(exp(-yt))
deriv(l::LogitMarginLoss, yt::Number) = -one(yt) / (one(yt) + exp(yt))
deriv2(l::LogitMarginLoss, yt::Number) = (eᵗ = exp(yt); eᵗ / abs2(one(eᵗ) + eᵗ))
value_deriv(l::LogitMarginLoss, yt::Number) = (eᵗ = exp(-yt); (log1p(eᵗ), -eᵗ / (one(eᵗ) + eᵗ)))

isunivfishercons(::LogitMarginLoss) = true
isdifferentiable(::LogitMarginLoss) = true
isdifferentiable(::LogitMarginLoss, at) = true
istwicedifferentiable(::LogitMarginLoss) = true
istwicedifferentiable(::LogitMarginLoss, at) = true
islipschitzcont(::LogitMarginLoss) = true
islipschitzcont_deriv(::LogitMarginLoss) = true
isconvex(::LogitMarginLoss) = true
isstronglyconvex(::LogitMarginLoss) = true
isclipable(::LogitMarginLoss) = false

# ==========================================================================
# L(y, t) = max(0, 1 - yt)

immutable L1HingeLoss <: MarginBasedLoss end
typealias HingeLoss L1HingeLoss

value{T<:Number}(l::L1HingeLoss, yt::T) = max(zero(T), one(T) - yt)
deriv{T<:Number}(l::L1HingeLoss, yt::T) = yt >= 1 ? zero(T) : -one(T)
deriv2{T<:Number}(l::L1HingeLoss, yt::T) = zero(T)
value_deriv{T<:Number}(l::L1HingeLoss, yt::T) = yt >= 1 ? (zero(T), zero(T)) : (one(T) - yt, -one(T))

isdifferentiable(::L1HingeLoss) = false
isdifferentiable(::L1HingeLoss, at) = at != 1
istwicedifferentiable(::L1HingeLoss) = false
istwicedifferentiable(::L1HingeLoss, at) = at != 1
islipschitzcont(::L1HingeLoss) = true
islipschitzcont_deriv(::L1HingeLoss) = true
isconvex(::L1HingeLoss) = true
isstronglyconvex(::L1HingeLoss) = false
isclipable(::L1HingeLoss) = true

# ==========================================================================
# L(y, t) = max(0, 1 - yt)^2

immutable L2HingeLoss <: MarginBasedLoss end

value{T<:Number}(l::L2HingeLoss, yt::T) = yt >= 1 ? zero(T) : abs2(one(T) - yt)
deriv{T<:Number}(l::L2HingeLoss, yt::T) = yt >= 1 ? zero(T) : T(2) * (yt - one(T))
deriv2{T<:Number}(l::L2HingeLoss, yt::T) = yt >= 1 ? zero(T) : T(2)
value_deriv{T<:Number}(l::L2HingeLoss, yt::T) = yt >= 1 ? (zero(T), zero(T)) : (abs2(one(T) - yt), T(2) * (yt - one(T)))

isdifferentiable(::L2HingeLoss) = true
isdifferentiable(::L2HingeLoss, at) = true
istwicedifferentiable(::L2HingeLoss) = false
istwicedifferentiable(::L2HingeLoss, at) = at != 1
islocallylipschitzcont(::L2HingeLoss) = true
islipschitzcont(::L2HingeLoss) = false
islipschitzcont_deriv(::L2HingeLoss) = true
isconvex(::L2HingeLoss) = true
isstronglyconvex(::L2HingeLoss) = true
isclipable(::L2HingeLoss) = true

# ==========================================================================
# L(y, t) = 0.5 / γ * max(0, 1 - yt)^2   ... yt >= 1 - γ
#           1 - γ / 2 - yt               ... otherwise

immutable SmoothedL1HingeLoss <: MarginBasedLoss
    gamma::Float64

    function SmoothedL1HingeLoss(γ::Number)
        γ > 0 || error("γ must be strictly positive")
        new(convert(Float64, γ))
    end
end

function value{T<:Number}(l::SmoothedL1HingeLoss, yt::T)
    yt >= 1 - l.gamma ? 0.5 / l.gamma * abs2(max(zero(T), one(T) - yt)) : one(T) - l.gamma / 2 - yt
end
function deriv{T<:Number}(l::SmoothedL1HingeLoss, yt::T)
    if yt >= 1 - l.gamma
        yt >= 1 ? zero(T) : (yt - one(T)) / l.gamma
    else
        -one(T)
    end
end
function deriv2{T<:Number}(l::SmoothedL1HingeLoss, yt::T)
    yt < 1 - l.gamma || yt > 1 ? zero(T) : one(T) / l.gamma
end
value_deriv(l::SmoothedL1HingeLoss, yt::Number) = (value(l, yt), deriv(l, yt))

isdifferentiable(::SmoothedL1HingeLoss) = true
isdifferentiable(::SmoothedL1HingeLoss, at) = true
istwicedifferentiable(::SmoothedL1HingeLoss) = false
istwicedifferentiable(l::SmoothedL1HingeLoss, at) = at != 1 && at != 1 - l.gamma
islocallylipschitzcont(::SmoothedL1HingeLoss) = true
islipschitzcont(::SmoothedL1HingeLoss) = true
islipschitzcont_deriv(::SmoothedL1HingeLoss) = true
isconvex(::SmoothedL1HingeLoss) = true
isstronglyconvex(::SmoothedL1HingeLoss) = false
isclipable(::SmoothedL1HingeLoss) = true

# ==========================================================================
# L(y, t) = max(0, 1 - yt)^2    ... yt >= -1
#           -4*yt               ... otherwise

immutable ModifiedHuberLoss <: MarginBasedLoss end

function value{T<:Number}(l::ModifiedHuberLoss, yt::T)
    yt >= -1 ? abs2(max(zero(T), one(yt) - yt)) : -T(4) * yt
end
function deriv{T<:Number}(l::ModifiedHuberLoss, yt::T)
    if yt >= -1
        yt > 1 ? zero(T) : T(2)*yt - T(2)
    else
        -T(4)
    end
end
function deriv2{T<:Number}(l::ModifiedHuberLoss, yt::T)
    yt < -1 || yt > 1 ? zero(T) : T(2)
end
value_deriv(l::ModifiedHuberLoss, yt::Number) = (value(l, yt), deriv(l, yt))

isdifferentiable(::ModifiedHuberLoss) = true
isdifferentiable(::ModifiedHuberLoss, at) = true
istwicedifferentiable(::ModifiedHuberLoss) = false
istwicedifferentiable(l::ModifiedHuberLoss, at) = at != 1 && at != -1
islocallylipschitzcont(::ModifiedHuberLoss) = true
islipschitzcont(::ModifiedHuberLoss) = true
islipschitzcont_deriv(::ModifiedHuberLoss) = true
isconvex(::ModifiedHuberLoss) = true
isstronglyconvex(::ModifiedHuberLoss) = false
isclipable(::ModifiedHuberLoss) = true
