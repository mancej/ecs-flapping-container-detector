
class SsmSvc:
    def __init__(self, boto_ssm):
        self._ssm = boto_ssm

    def get_from_ps(self, key):
        parameter = self._ssm.get_parameter(Name=key, WithDecryption=True)
        return parameter['Parameter']['Value']