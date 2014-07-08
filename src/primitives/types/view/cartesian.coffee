View = require('./view')

class Cartesian extends View

  make: () ->
    super

    @uniforms =
      viewMatrix:          @_attributes.make @_types.mat4()

    @viewMatrix          = @uniforms.viewMatrix.value
    @rotationMatrix      = new THREE.Matrix4()

    @scale               = new THREE.Vector3(1, 1, 1)

  unmake: () ->
    super

    delete @viewMatrix
    delete @rotationMatrix
    delete @positionMatrix
    delete @scale

  change: (changed, touched, init) ->

    return unless touched['object'] or touched['view'] or init

    o = @_get 'object.position'
    s = @_get 'object.scale'
    q = @_get 'object.rotation'
    r = @_get 'view.range'

    x = r[0].x
    y = r[1].x
    z = r[2].x
    dx = (r[0].y - x) || 1
    dy = (r[1].y - y) || 1
    dz = (r[2].y - z) || 1
    sx = s.x
    sy = s.y
    sz = s.z

    # Forward transform
    @viewMatrix.set(
      2*sx/dx, 0, 0, -(2*x+dx)*sx/dx,
      0, 2*sy/dy, 0, -(2*y+dy)*sy/dy,
      0, 0, 2*sz/dz, -(2*z+dz)*sz/dz,
      0, 0, 0, 1 #,
    )
    @rotationMatrix.compose o, q, @scale
    @viewMatrix.multiplyMatrices @rotationMatrix, @viewMatrix

    @trigger
      type: 'range'

  to: (vector) ->
    vector.applyMatrix4 @viewMatrix

  transform: (shader) ->
    shader.call 'cartesian.position', @uniforms
    @parent?.transform shader

  ###
  from: (vector) ->
    this.inverse.multiplyVector3(vector);
  },
  ###

module.exports = Cartesian
