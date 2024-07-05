# bem-to-surrogate-docker
Take the openstudio-bem-to-surrogate-gem repo from NREL and make a dockerfile that runs the measures test github action workflow. The dockerfile doesn't actually run the tests but creates an image that can be used in a container where you can run the tests in the measures test github action workflow.

# Build instructions
Use the following command while in the root directory of this `bem-to-surrogate-docker` repo:
```
docker build -f Dockerfile -t openstudio-bem-to-surrogate ..
```

This will work as long as the `openstudio-bem-to-surrogate-gem` repo is in an adjacent directory to the current directory. I.E. they should have the same parent directory.

