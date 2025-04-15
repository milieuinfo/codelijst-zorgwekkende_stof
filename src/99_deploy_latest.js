import { deploy_latest } from 'maven-metadata-generator-npm';
import { set_env } from './utils/setenv.js';

const omgeving = 'oe'
set_env(omgeving)
deploy_latest(omgeving)
